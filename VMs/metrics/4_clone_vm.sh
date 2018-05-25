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

message "Removing any exising VM clone"
./7_delete_clone.sh "${CONFIG_DIR}"

message "Cloning ${VM_NAME} into ${VM_CLONE_NAME}"
# By default the CDROM ISO would be shared with the master as it is read only,
# but later when we delete a clone we delete all of its storage, so we need our
# own separate copy - so force the CDROM (hda) copy.
virt-clone -o ${VM_NAME} -n ${VM_CLONE_NAME} --auto-clone --force-copy hda

