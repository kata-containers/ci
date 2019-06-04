//
// Copyright (c) 2019 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0
//
// Kata Containers Jenkins CI pipeline.
// Written in Jenkins Declarative pipeline style.
//
// Prereqs:
//  In order to use the 'readJSON' and 'readYaml' functions, this pipeline
// requires the 'pipeline-utility-steps' plugin to be installed.
//
//  If you wish to use the 'rebuild' plugin with this pipeline, you may
//  need to enable passing 'null' env vars through to rebuilds by executing
//  the following in your Jenkins master script console:
//  System.setProperty("hudson.model.ParametersAction.keepUndefinedParameters", "true")
//
//  In order to curl from the github API and not run into rate limiting issues,
//  you should lodge your github access token in your Jenkins master keystore
//  and match the ID with the name defined in this script in the 'credentials()' call.

// Setting 'SKIPTESTS' to 'true' will skip later steps of the pipeline.
// Used to short-circuit *pass* the CI. e.g., if the script finds a
// github label of 'skip-ci', it will short-circuit return success to
// enable a CI fastpath for PRs that are known not to need a full CI test.
def SKIPTESTS
// Make a note of when we did do the check, so we can warn when we cannot
// do it (probalby due to lack of set env vars)
def DID_SKIPTEST = 'false'
// The github label we look for. If found, we skip the main body of the
// CI checks.
def SKIPLABEL='skip-ci'
// The matrix of repos/distros/tests we load from the test matrix YAML file
def testmatrix_file='Jenkins.yaml'
// Do not 'def' this map, or it will be out of scope for the test running functions.
testmatrix=[:]

pipeline {

  // Set the node to 'none' at the global level, so we can then allocate
  // specific nodes to specific steps later on. This allows us to run any
  // fast lightweight steps on the master (to save spinning up a container
  // or VM node), and also to use specific nodes for specific tests, such
  // as distro or arch specific tests.
  agent none

  // Set up some required environment vars
  environment {
    // Sigh, we can't get to WORKSPACE at this point, which in some ways might
    // make sense, as it could be different for each node/agent. sigh.
    //GOPATH="${PWD}/go"
    GOPATH="go"
    // FIXME - how do we edit the PATH ??
    //PATH="${GOPATH}/bin:/usr/local/go/bin:/usr/sbin:/sbin:${env.PATH}"

    // Kata related variables:
    CI="true"
    // We need the tests repo to run the CI scripts
    tests_repo="github.com/kata-containers/tests"
    tests_repo_dir="${GOPATH}/src/${tests_repo}"
    // We need the runtime repo to get the latest kata versions.yaml file to ensure
    // we install and test with the required tool versions.
    runtime_repo="github.com/kata-containers/runtime"
    runtime_repo_dir="${GOPATH}/src/${runtime_repo}"
    // We need the CI repo to get access to the Jenkins.yaml test matrix file.
    ci_repo_name="kata-containers/ci"
    ci_repo="github.com/${ci_repo_name}"
    ci_repo_dir="${GOPATH}/src/${ci_repo}"

    // This has to be a string, so cannot be placed in a global var :-(
    GITHUB_API_TOKEN = credentials('cc70853d-7fac-4976-be2d-093d7d366fb1')
  }

  stages {

    // DEBUG, FIXME, show the env, as that is always helpful during debug
    stage('Show env') {
      agent { label "master" }
      steps {
          script {
          echo "Showing our inner env:"
          printEnv()
          echo "Showing our shell env:"
          sh "env"
        }
      }
    }

    // Clean up any previous workspace - otherwise we can run into some
    // file clashes, like on 'git clone'.
    stage('Clean workspace') {
      agent { label "master" }
      steps {
        cleanWs()
      }
    }

    // Do some prechecks. Check that we really do need to run the CI tests on this
    // PR.
    stage('Prechecks') {
      // Run these checks on the Master node. This saves us having to spin up a
      // node container or VM, so saves us time and resource.
      agent { label "master" }
      when {
        // If none of these are set, then we can't do the curl to get the list of
        // github labels. Currently we then fall through, warn we have not done the
        // check, and then run the CI. We *could* skip the CI in this situation if
        // we wanted to...
        allOf {
          expression { GITHUB_API_TOKEN != null }
          expression { env.ghprbGhRepository != null }
          expression { env.ghprbPullId != null }
        }
      }
      steps {
        script {
          DID_SKIPTEST='true'
          // Curl the github labels for this PR (the ghprb plugin does not supply them directly),
          // and then check if we have the 'fast track the CI' label set.
          json=sh(script: "/usr/bin/curl -H \"Authorization: Basic ${GITHUB_API_TOKEN}\" https://api.github.com/repos/${env.ghprbGhRepository}/issues/${env.ghprbPullId}/labels", returnStdout: true).trim()

          // Convert the labels JSON to a list of maps, one map per label
          labs = readJSON text: "${json}"
          // Check if we have the 'skip the CI' label applied
          labs.each { labmap ->
            if ( labmap['name'] == SKIPLABEL ) {
              echo "Found CI skip label, skipping further tests"
              SKIPTESTS='true'
            }
          }
          if ( SKIPTESTS != 'true' ) {
            echo "CI fastpath not set, running full pipeline"
          }
        }
      }
    }

    // Warn when we failed to do the precheck. This is not idea, as it will appear
    // as an extra stage. it would be great if the above 'when' check had an 'else'
    // clause we could use, but afaict, it does not.
    stage('CheckPrecheck') {
      agent { label "master" }
      when {
        expression { DID_SKIPTEST == 'false' }
      }
      steps {
        echo "Warning, skipped CI skip check"
      }
    }

    // We will always need some of these to run the static checks.
    // We need to git clone the:
    // - tests repo so we can use some of its CI scripts
    // - rutime repo to get the versions.yaml file
    // - ci repo to get the Jenkins test matrix YAML
    stage('Setup test repo environment') {
      agent { label "master" }
      steps {
        sh '''
          git clone "https://${tests_repo}.git" "${WORKSPACE}/${tests_repo_dir}"
          git clone "https://${runtime_repo}.git" "${WORKSPACE}/${runtime_repo_dir}"
          git clone "https://${ci_repo}.git" "${WORKSPACE}/${ci_repo_dir}"
        '''
      }
    }

    // Always run the static checks, even if we have a 'skip-ci' label.
    // Later we could add a 'really-skip-ci' label if we needed etc. to
    // not even run the static checks??
    // If the PR does not pass the static checks,
    // then the rest of the CI checks will be skipped by Jenkins.
    stage('Static checks') {
      agent { label "master" }
      steps {
        script {
          echo "In static check"
        }
      }
    }

//    stage('examine the rootdir') {
//      agent { label "master" }
//      steps {
//        script {
//          sh "pwd"
//          sh "ls"
//        }
//      }
//    }

    // Load up our test matrix data from the YAML file so we can tell
    // which tests are to be run on which distro/jobs
    stage('Load test matrix data') {
      agent { label "master" }
      steps {
// FIXME - if we are test the CI repo, then we need to pick the config file up from the
// Jenkins checked out PR (root of WORKSPACE), and not the golang checked out
// ci repo. Code that up when we have access to the ghprbGhRepository var...
// FIXME
// // By default we run the tests using the git checkout out test repo
// testcode_rootdir = env.ci_repo_dir
// if ( env.ghprbGhRepository != null ) {
//   // but, if this PR is from the tests repo, use the Jenkins checked out
//   // source/branch of that instead, in case the PR is updating the test code.
//   if ( env.ghprbGhRepository == env.ci_repo_name ) {
//     testcode_rootdir = ""
//   }
// }
        //dir("${testcode_rootdir}") {
          script {
            sh "pwd"
            sh "ls"
            testmatrix = readYaml file: "${testmatrix_file}"
            echo "testmatrix looks like ${testmatrix}"
         // }
        }
      }
    }

    // Run the CI on the primary distro (note, that does not mean this is our
    // favoured distro, it just means we needed to pick one as the primary
    // smoke test). If the primary distro does not pass, the rest of the distro
    // tests will be skipped by Jenkins.
    stage('Ubuntu18.04') {
      when {
        expression { SKIPTESTS != 'true' }
      }
      agent { label "master" }
      steps {
        echo "Am running ${STAGE_NAME}"
        testrunner ( STAGE_NAME )
      }
    }

    // If we have passed all previous steps, finally we can parallel run the
    // rest of the distro checks.
    stage('Run main jobs') {
      when {
        expression { SKIPTESTS != 'true' }
      }
      parallel {
        stage('Fedora') {
          agent { label "master" }
          steps {
            echo "Am running ${STAGE_NAME}"
            testrunner ( STAGE_NAME )
          }
        }
        stage('Centos') {
          agent { label "master" }
          steps {
            echo "Am running ${STAGE_NAME}"
            testrunner ( STAGE_NAME )
          }
        }
      }
    }
  }
}


// Run our tests on the 'distroName' distro provided.
// Use that name to look in the testmatrix to work out which tests
// are to be run on this repo/distro combination.

def testrunner(distroName) {
  echo "Running tests for distro (${distroName})"

  // Check here so we can mark a 'stage' as skipped
  if ( env.ghprbGhRepository == null ) {
    stage('skipping') {
      echo "Skipping tests, ghprbGhRepository variable not set"
      // This only returns out of this stage...
      return
    }
  }

  // And now really return from this func
  if ( env.ghprbGhRepository == null ) {
    return
  }

  echo "testmatrix looks like ${testmatrix}"
  testmap = testmatrix[env.ghprbGhRepository]
  echo "testmap[repo] looks like ${testmap}"
  testmap = testmatrix[env.ghprbGhRepository][distroName]
  echo "testmap[repo][distro] looks like ${testmap}"

  echo "testmap['docker'] looks like ${testmap['docker']}"

  if ( testmap['docker'] == true ) {
    stage('docker') {
      dir("${GOPATH}/src/${env.ghprbGhRepository}") {
        echo "Running docker tests"
        sh "pwd"
        sh "echo make docker"
      }
    }
  } else {
    echo "Docker tests disabled for ${distroName}/${env.ghprbGhRepository}"
  }
}

@NonCPS
def printEnv() {
  env.getEnvironment().each { name, value -> println "Name: $name -> Value $value" }
}
