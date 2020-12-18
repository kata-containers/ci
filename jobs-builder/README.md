# Overview

Manage the Jenkins jobs with help of the [Jenkins Job Builder](https://docs.openstack.org/infra/jenkins-job-builder).

# Getting started

First of all, you need to install Jenkins Job Builder in your environment. The
instructions can be found [here](https://docs.openstack.org/infra/jenkins-job-builder/installation.html).

To use the Jenkins Job Builder it is needed a configuration file which contains
the Jenkins URL, user and token API to manage Jenkins, among other information
that sets the tool's behavior. That file can copied from the `jjb.conf.template`
template then filling out the fields marked with *XXX*.

Bootstrapping your environment:
```bash
pip install --user jenkins-job-builder
cp jjb.conf.template jjb.conf
sed -i 's/user=XXX/user=my_user/' jjb.conf
sed -i 's/password=XXX/password=my_user_token/' jjb.conf
```

# Managing the jobs

Use the `publish_jobs.sh` to update all the Jenkins Job Builder managed jobs.

Example of use:
```bash
./publish_jobs.sh -c jjb.conf
```

If you only want to check the jobs can be generated but not actually publish
them all then do:
```bash
./publish_jobs.sh -c jjb.conf -t
```
