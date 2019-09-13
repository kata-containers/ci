# Kata Containers CI

* [Jenkins CI](#jenkins-ci)
    * [Jenkins CI slave deployment scripts](#jenkins-ci-slave-deployment-scripts)
    * [Metrics CI](#metrics-ci)
* [CI Job Matrix](#ci-job-matrix)
* [CI health status](#ci-health-status)
* [Controlling the CI](#controlling-the-ci)

This repository stores configuration for the Kata Containers Continuous Integration (CI) system.

# Jenkins CI

The default CI system for Kata Containers is [Jenkins](https://jenkins.io/). See
the [Jenkins Setup](Jenkins_setup.md) document for more details.

## Jenkins CI slave deployment scripts

See [the Jenkins CI slave deployment documentation](deployment/packet/README.md).

## Metrics CI

See [the metrics CI documentation](VMs/metrics/README.md).

# CI Job Matrix

We run several jobs on the Kata Containers CI to ensure that different
architectures and configurations are properly tested. Below you can find a
matrix of what jobs/configuration we currently use and the tests we run
against them.

| Job                     | Hypervisor - Machine Type | Guest Image | Architecture |               | Docker             | CRI-O              | Containerd         | Kubernetes         | OpenShift          | Docker stability   | OCI                | network            | `netmon`             | VM-templating      | `shimv2 - containerd` | entropy            | ramdisk            | tracing            |
|-------------------------|---------------------------|-------------|-------------|---------------|--------------------|--------------------|--------------------|--------------------|--------------------|--------------------|--------------------|--------------------|--------------------|--------------------|---------------------|--------------------|--------------------|--------------------|
| `centos-7.4-firecracker`  | firecracker               | rootfs      | `x86_64`      | :arrow_right: | :heavy_check_mark: |                    |                    |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                    |                     |                    |                    |                    |
| `centos-7.4-q35`          | `qemu - q35`                | rootfs      | `x86_64`      | :arrow_right: | :heavy_check_mark: |                    |                    | :heavy_check_mark: |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `debian-10`               | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: |                    | :heavy_check_mark: |                    |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `fedora-28`               | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: |                    | :heavy_check_mark: |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `opensuse` 15             | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: | :heavy_check_mark: | :heavy_check_mark: |                    |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `rhel-7`                  | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: |                    |                    |                    |                    |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `sles-12-SP4`             | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: |                    |                    |                    |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `ubuntu-18.04`            | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: |                    | :heavy_check_mark: |                    | :heavy_check_mark: |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `ubuntu-18.04-containerd` | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: |                    |                    | :heavy_check_mark: | :heavy_check_mark: |                    |                    |                    |                    |                    |                    |                     |                    |                    |                    |
| `ubuntu-18.04-initrd`     | `qemu - PC`                 | initrd      | `x86_64`      | :arrow_right: | :heavy_check_mark: |                    |                    | :heavy_check_mark: |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| `ubuntu-18.04-nemu`       | `nemu - virt` + `virtiofs`  | rootfs      | `x86_64`      | :arrow_right: | :heavy_check_mark: |                    |                    |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    |                    |                     |  |  |  |
| `ubuntu-18.04-aarch64`    | `qemu - virt`               | rootfs      | `arm64`       | :arrow_right: | :heavy_check_mark: |                    |                    |                    |                    |                    |                    |                    |                    |                    |                     |                    |                    |                    |
| `ubuntu-18.04-s390x`      | `qemu - s390-ccw-virtio`    | initrd      | `s390x`       | :arrow_right: | :heavy_check_mark: |                    |                    |                    |                    |                    |                    |                    |                    |                    |                     |                    |                    |                    |
| `ubuntu-16.04-Power8`     | [WIP](https://github.com/kata-containers/ci/issues/100) | WIP         | `Power8`      | :arrow_right: |                    |                    |                    |                    |                    |                    |                    |                    |                    |                    |                     |                    |                    |                    |
| `ubuntu-18.04-vsocks`     | `qemu - PC`                 | rootfs      | `x86_64`      | :arrow_right: | :heavy_check_mark: |                    |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |                    | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |

# CI health status

You can check for any known CI system issues [via this link](http://jenkins.katacontainers.io/view/CI%20Status/).

# Controlling the CI

The Jenkins CI jobs can be controlled (such as re-triggered or skipped) in a number of ways. Details of the
control trigger phrases are listed on
[a community repo wiki page](https://github.com/kata-containers/community/wiki/Controlling-the-CI).
