# Kata Containers Jenkins CI slave deployment scripts

* [Pre-requisites](#pre-requisites)
* [Local setup](#local-setup)
* [Creating an instance](#creating-an-instance)
* [Configuring an instance](#configuring-an-instance)
* [Testing the instance](#testing-the-instance)
* [Installing the Metrics VMs](#installing-the-metrics-vms)
* [Configuring `checkmetrics`](#configuring-checkmetrics)
* [Integration into the Jenkins master](#integration-into-the-jenkins-master)
* [Deleting an instance](#deleting-an-instance)

This directory contains a set of [Ansible](https://docs.ansible.com/) scripts to help
deploy Kata metrics CI build slaves on the [packet.net](https://www.packet.com/) cloud.

These scripts help:
- Create a new bare metal machine instance in the packet.net cloud
- Configure an instance with the components necessary to be able to run both:
  - The [Kata metrics CI VMs](https://github.com/kata-containers/ci/tree/master/VMs/metrics)
    as per the [Pre-requisites](https://github.com/kata-containers/ci/tree/master/VMs/metrics#pre-requisites) listed on that page.
  - The instances as bare metal Jenkins CI slaves.
- Provide a helper to delete existing instances.

## Pre-requisites

In order to execute these scripts you will need a few pre-requisites installed and
configured on your host system:

- `Ansible` (version >= v2.3).
- `packet-python` - see [the Ansible guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_packet.html) for details.
- A Kata Containers packet.net project [token](https://www.packet.com/developers/api/).
- The Kata Containers packet.net root user SSH private key pair.
- The Kata Containers packet.net Jenkins user SSH private key pair.
- A copy of the required golang version Linux [tarball](https://golang.org/dl/)

## Local setup

- Export your packet.net token into your environment, as detailed on the Ansible packet [documentation page](https://docs.ansible.com/ansible/latest/scenario_guides/guide_packet.html#requirements)
- Place your packet.net root user SSH keys into your `${HOME}/.ssh` directory, ready for Ansible to use later (expected name is `packet_rsa[.pub]`)
- Place your packet.net Jenkins user SSH keys into your `${HOME}/.ssh` directory, ready to test later (expected name `kata-metric1[.pub]`)
- Download a copy of the golang install tarball into this directory.

## Creating an instance

To create an instance, check the following settings in the `install_packet.yaml` file match
your required system:

- hostnames
- operating_system
- plan
- facility

The `project_id` field should already be configured for the correct project. You should have
already set the correct `PACKET_API_TOKEN` in your environment.

Run the Following command. All phases should pass, and you should have no failures
reported:

```bash
$ ansible-playbook create_packet.yaml
```

This will deploy a new instance on packet.net, and wait for it to finish booting.
The script will print out the machine details. Save these for later, as you will require
the public IP address the instance has been allocated. You can also find the IP address
of the instance on the packet.net web interface.

## Configuring an instance

The instance now needs to be configured and have the correct packages and users installed
before it can be used for Kata Containers metrics CI.

Ansible achieves this by logging into the system using SSH as the `root` user to run the relevant
configuration commands. Before executing the installation script, the root user SSH keys
need to be configured and tested.

Using the public IP address recorded in the deployment phase above, configure your
`${HOME}/.ssh/config` file similar to below, replacing the `AAA.BBB.CCC.DDD` with the
relevant IP address:

```bash
# packet c1small-test
host AAA.BBB.CCC.DDD
 ServerAliveInterval 30
 User root
 IdentityFile ~/.ssh/packet_rsa
 IdentitiesOnly yes
```

Test this configuration such as:

```bash
$ ssh root@AAA.BBB.CCC.DDD
```

If the configuration is correct, you should be logged into the packet.net instance.
Your system may ask to add the instance key to your `known_hosts` file, which may
be necessary to perform the next step. Now exit the `ssh` session.

You also need to configure Ansible to recognise the new instance as a valid host. This can
be done with some local configuration files.

Create an `ansible.cfg` file in the current directory, with the following contents, whilst
substituting the `<path to this directory>` with the full path to where these files are
located on your system:

```
[defaults]

inventory = <path to this directory>/ansible_hosts
```

Create an `ansible_hosts` file on in this directory, with the contents:

```
AAA.BBB.CCC.DDD
```

replacing `AAA.BBB.CCC.DDD` with the IP address of the instance obtained during creation.

To configure the instance, edit the `install_packet.yaml` file and change the `hosts:`
line to reflect the AAA.BBB.CCC.DDD IP address obtained during instance creation.

Save this change, then execute the following:

```bash
$ ansible-playbook install_packet.yaml
```

All steps should pass successfully, and Ansible should report no failures.
Your instance should now be configured to execute Jenkins CI tasks either on the
"bare metal", or inside a Metrics VM.

## Testing the instance

Now the instance is deployed and configured, we can test that the Jenkins user is set up
correctly. Add the Jenkins user SSH key into your .ssh configuration:

```bash
# packet c1small-test jenkins user
host AAA.BBB.CCC.DDD
 ServerAliveInterval 30
 User jenkins
 IdentityFile ~/.ssh/kata-metric1
 IdentitiesOnly yes
```

Test the configuration:

```bash
$ ssh jenkins@AAA.BBB.CCC.DDD
```

This should log you into the instance as the `jenkins` user.

## Installing the Metrics VMs

If you are intending to use the metrics VMs, remain logged in as the Jenkins user.
Execute the following to set the final necessary environment setting:

```bash
$ export PATH=/usr/local/go/bin:$PATH
```

and follow the instructions on the [metrics VMs](https://github.com/kata-containers/ci/tree/master/VMs/metrics#example)
page to complete the installation ready to deploy the instance into the CI Jenkins master.

## Configuring `checkmetrics`

A metrics machine must have a valid `checkmetrics` configuration file in `/etc/checkmetrics`
in order to verify the metrics CI results.

To aid setup of this file on the bare metal metrics slaves, the `add_checkmetrics.yaml`
Ansible script can be used. A local `checkmetrics` TOML file must be present in the same`
directory where you execute the script, with the name form `checkmetrics-json-<uname>.toml`,
where `<uname>` is the name of the remote slave, as set in `create_packet.yaml`, and returned
by `uname -n` on that slave.

To copy the TOML file to the slave, edit the `add_checkmetrics.yaml` file, replacing
`AAA.BBB.CCC.DDD` with the IP address of the instance. Then execute the following:

```bash
$ ansible-playbook add_checkmetrics.yaml
```

## Integration into the Jenkins master

The slave instance can now be integrated into the Jenkins master as a build machine. Details
can be found [in this document](https://github.com/kata-containers/ci/blob/master/Jenkins_setup.md)

## Deleting an instance

The `delete_packet.yaml` Ansible script is provided as a helper in case an existing
packet.net instance needs to be removed. These can also be removed using the packet.net
web interface.
