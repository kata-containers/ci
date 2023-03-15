// Copyright (c) 2023 Red Hat, Inc.
// SPDX-License-Identifier: Apache-2.0
//
// The kata-containers, kata-containers/tests, and confidential-containers/operator repositories are monitored by polling,
// in case of changes are detected it will wait for the runtime-payload (and other images) to show up on the registry,
// afterwards tests jobs are triggered.

// Define jobs configurations
def jobsConfig = [
    'cc-ci-ubuntu-20.04-x86_64-containerd_kata-qemu': [runtimeClass: 'kata-qemu',
                                                 node: 'ubuntu_20.04',
                                                 arch: 'x86_64',
                                                 baremetal: false],
    'cc-ci-ubuntu-20.04-x86_64-containerd_kata-clh': [runtimeClass: 'kata-clh',
                                                node: 'ubuntu_20.04',
                                                arch: 'x86_64',
                                                baremetal: false],
//    'cc-ci-ubuntu-20.04-x86_64-containerd_kata-qemu-sev': [runtimeClass: 'kata-qemu-sev',
//                                                     node: 'amd-ubuntu-2004_op-ci',
//                                                     arch: 'x86_64',
//                                                     baremetal: true]
]

def jobs = [:]
def jobsArches = jobsConfig.collect { "$it.value.arch" }.unique()
// The new runtime-payload image
def payloadNewImg = "confidential-containers/runtime-payload-ci"
// The new runtime-payload image tag (the -arch suffix is omitted)
def payloadNewImgTag = ""
// The confidential-containers/operator repository latest commit SHA-1
def operatorCommit = ""
// The kata-containers repositories branch it should monitor
def kataRepoBranch = "CCv0"
// The amount of time in minutes it should wait for the images be built.
def waitImagesTimeout = 90

// Keep polling the repositories for new changes.
node("amd-ubuntu-2004_op-ci") {
    def kataCommit = ""

    stage("Checkout SCM") {
        dir("kata-containers") {
            checkout(poll: true,
                     scm: [$class: 'GitSCM',
                           branches: [[name: kataRepoBranch]],
                           extensions: [],
                           userRemoteConfigs: [[url: 'https://github.com/kata-containers/kata-containers']]])

            kataCommit = sh(returnStdout: true, script: 'git rev-list --max-count=1 HEAD').trim()
        }
        dir("tests") {
            checkout(poll: true,
                     scm: [$class: 'GitSCM',
                           branches: [[name: kataRepoBranch]],
                           extensions: [],
                           userRemoteConfigs: [[url: 'https://github.com/kata-containers/tests']]])
        }
        dir("operator") {
            checkout(poll: true,
                     scm: [$class: 'GitSCM',
                           branches: [[name: 'main']],
                           extensions: [],
                           userRemoteConfigs: [[url: 'https://github.com/confidential-containers/operator']]])
            operatorCommit = sh(returnStdout: true, script: 'git rev-list --max-count=1 HEAD').trim()
        }
    }

    stage("Wait for images") {
        // This job should be triggered just after a push to the repositories and the images might not be built, so
        // keep polling the registry until they show up.

        // TODO: add support for s390x.
        payloadNewImgTag = "kata-containers-" + kataCommit
        timeout(time: waitImagesTimeout, unit: 'MINUTES') {
          sh """
          for arch in ${jobsArches.join(' ')}; do
            payload_img_tag="${payloadNewImgTag}-\$arch"
            tag=""
            while [ -z "\$tag" ]; do
              sleep 60
              tag=\$(curl -s https://quay.io/api/v1/repository/${payloadNewImg} | grep "\$payload_img_tag") || true
            done
          done
          """
        }
    }
}

// Define the tests jobs which are the operator CI ones.
jobsConfig.each { key, c ->
    jobs[key] = {
        node(c['node']) {
            def arch = c['arch']
            def undoFlag = ""

            if (c['baremetal']) {
              undoFlag="-u"
            }
            stage("Bootstrap test node") {
                sh "sudo apt-get update -y"
                sh "sudo apt-get install -y ansible python-is-python3"
            }
            stage("Checkout operator source") {
                dir("operator") {
                    checkout(poll: true,
                           scm: [$class: 'GitSCM',
                           branches: [[name: operatorCommit]],
                           extensions: [],
                           userRemoteConfigs: [[url: 'https://github.com/confidential-containers/operator']]])
                }
            }
            stage("Prepare the operator deploy") {
                // Update the deployment files to leverage the new runtime-payload and other images.

                dir("operator") {
                    sh """
                    [ -f "./kustomize" ] || \
                        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
                    cd config/samples/ccruntime/default
                    ../../../../kustomize edit set image \
                        quay.io/confidential-containers/runtime-payload=quay.io/${payloadNewImg}:${payloadNewImgTag}-${arch}
                    cat kustomization.yaml
                    """
                }
            }
            stage("Run tests") {
                withCredentials([string(credentialsId: 'quay_kata-containers-cc_auth_bot_creds',
                                        variable: 'REGISTRY_CREDENTIAL_ENCODED')]) {
                    dir("operator") {
                        sh """
                          export PATH="$PATH:/usr/local/bin"
                          ./tests/e2e/run-local.sh -r ${c['runtimeClass']} ${undoFlag}
                        """
                    }
                }
            }
       }
    }
}

// Run the tests jobs.
parallel jobs
