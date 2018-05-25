#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

#Presently we share the same standard key across all the VMs.
# TODO - add the ability to the env file processing to over-ride the key paths
PRIVKEYNAME=$(pwd)/virsh.rsa
PUBKEYNAME=${PRIVKEYNAME}.pub

ENV_FILE=env.sh
META_DATA_NAME=meta-data
USER_DATA_NAME=user-data

VM_USERNAME=jenkins
# Common SSH/SCP options we use
SSH_OPTS="-F /dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ${PRIVKEYNAME}"

# Seconds to wait for VM to launch (and get on network)
VM_BOOTTIME=30

# Default image size for the VMs, in Gigabytes
VM_IMAGE_SIZE=10
# Default number of vCPUs per VM
VM_VCPUS=2
# Default ramsize for VMs, in Megabytes
VM_RAM_SIZE=8192

IMG_DIR=~/vms


