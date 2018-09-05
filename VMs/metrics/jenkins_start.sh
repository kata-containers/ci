#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

ROOTDIR=${HOME}/kata-containers-ci/VMs/metrics
# Ensure virsh can see the correct domain for our VMs.
# On some systems a Jenkins ssh connection will connect to
# qemu:///session by default, and thus will fail to clone/run
# a new VM.
export LIBVIRT_DEFAULT_URI=qemu:///system

if [ $# -ne 1 ]; then
	echo "Require VM config name as only parameter"
	exit 1
fi

cd ${ROOTDIR}
./6_start_clone_agent.sh $1

echo "Done $0"
