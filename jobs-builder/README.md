# Overview

Manage the Jenkins jobs with help of the [Jenkins Job Builder](https://docs.openstack.org/infra/jenkins-job-builder) (JJB).

The JJB converts jobs and views from YAML representations into the Jenkins XML
configuration files. Also the tool is able to manage jobs, for example, publish
the generated jobs and views in a running Jenkins instance.

# Getting started

First of all, you need to install Jenkins Job Builder in your environment. The
instructions can be found [here](https://docs.openstack.org/infra/jenkins-job-builder/installation.html).

To use the Jenkins Job Builder a configuration file is needed which contains
the Jenkins URL, user and token API to manage Jenkins, among other information
that sets the tool's behavior. That file can copied from the `jjb.conf.template`
template then filling out the fields marked with *XXX*.

Bootstrapping your environment:
```bash
$ pip install --user jenkins-job-builder
$ cp jjb.conf.template jjb.conf
$ sed -i 's/user=XXX/user=my_user/' jjb.conf
$ sed -i 's/password=XXX/password=my_user_token/' jjb.conf
```

# Managing the jobs

Use the `publish_jobs.sh` to update all the Jenkins Job Builder managed jobs.

Example of use:
```bash
$ ./publish_jobs.sh -c jjb.conf
```

If you only want to check the jobs can be generated but not actually publish
them all then do:
```bash
$ ./publish_jobs.sh -c jjb.conf -t
```

Run `./publish_jobs.sh -h` to see all the available options of the script.

# Checking your changes on a local Jenkins

Often you will need to see how the jobs look like on the Jenkins UI in order
to check that the generated configurations are correct. The easiest way to
accomplish that is to publish the jobs on a local Jenkins instance. Use the
following instructions to setup a sandbox locally, but beware that it won't be
exactly alike the instance on production, although for the purpose of checking
the configurations it works out.

 1. Start the Jenkins container

The following command creates the Jenkins container, and the instance service
will be accessible through the port 8080 on the local host.

```bash
$ docker run --rm -p 8080:8080 --name=jenkins-container -d jenkins/jenkins
```

 2. Give an initial configuration

Using your web browser, access Jenkins from [http://localhost:8080](http://localhost:8080).

The first displayed page asks for the initial administrator password, which can
be obtained with the following command:

```bash
$ docker exec jenkins-container cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste that token on the "administrator password" field then continue with the
setup. You will be asked to install plugins (select to install all) and finally
to create an account.

 3. Create the API token

Access your new user account (on the top-right menus) then go to "Configure".
Click "Add new Token" then on the "Generate" button. Save the generated token.

 4. Create the JJB configuration file

Now you need to create the `jjb.conf` as explained on [Getting started](#getting-started). Use
the user name and API token created on the previous steps, and don't forget to set
the `url` property to `http://localhost:8080`.
