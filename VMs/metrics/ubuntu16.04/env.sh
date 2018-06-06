#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

# Set the name that virsh/libvirt will use, and also gets set as the uname/hostname
# inside the VM.
# Name carefully, as there are restrictions on the valid character set and length of
# name - see:
# https://libvirt.org/formatdomain.html#elementsMetadata
# https://en.wikipedia.org/w/index.php?title=Hostname&section=4#Restrictions_on_valid_hostnames
VM_NAME_BASE="ubnt1604"
VM_NAME="${VM_NAME_BASE}Master"
VM_CLONE_NAME="${VM_NAME_BASE}Clone"
# The virt-install os-variant type. See `osinfo-query os` for a list of valid variants.
# These scripts currently presume the OS_TYPE is Linux.
VM_VARIANT="ubuntu16.04"
IMG_BASE=${IMG_DIR}/xenial-server-cloudimg-amd64-disk1.img
IMG_BASE_SOURCE=https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
