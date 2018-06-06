#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

source global_env.sh
source lib.sh

if [ $# != 1 ]; then
	error "Missing first argument"
	die "Usage: $0 distro_config_dirname"
fi

CONFIG_DIR="$1"

if [ ! -f "${CONFIG_DIR}/${ENV_FILE}" ]; then
	die "Env file ${CONFIG_DIR}/${ENV_FILE} missing"
fi

source "${CONFIG_DIR}/${ENV_FILE}"

# We could be smarter and check if it is already running...
message "Starting clone VM"
virsh start ${VM_CLONE_NAME}

message "Napping for ${VM_BOOTTIME}s for VM to come up"
sleep ${VM_BOOTTIME}

VM_IP=$(virsh domifaddr ${VM_CLONE_NAME} | tail -2 | head -1 | awk '{print $4}')
VM_IP=${VM_IP%%/*}

echo "IP of ${VM_CLONE_NAME} is ${VM_IP}"
ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP}
