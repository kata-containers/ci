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

message "Removing ${VM_CLONE_NAME}"
virsh shutdown ${VM_CLONE_NAME}
virsh destroy ${VM_CLONE_NAME}
virsh undefine --remove-all-storage ${VM_CLONE_NAME}

