# Kata Containers CI

* [Jenkins CI](#jenkins-ci)
    * [Jenkins CI slave deployment scripts](#jenkins-ci-slave-deployment-scripts)
    * [Metrics CI](#metrics-ci)
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

# CI health status

You can check for any known CI system issues [via this link](http://jenkins.katacontainers.io/view/CI%20Status/).

# Always green CI

See the [Always Green CI](Always_green_CI.md) document for details.

# Controlling the CI

The Jenkins CI jobs can be controlled (such as re-triggered or skipped) in a number of ways. Details of the
control trigger phrases are listed on
[a community repo wiki page](https://github.com/kata-containers/community/wiki/Controlling-the-CI).

# Jobs builder

See [README](jobs-builder/README.md) for information about the use of Jenkins Job Builder (JJB) to make the CI jobs.
