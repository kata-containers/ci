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

# FIXME - We could be smarter and check if it is already running...

VM_IP=$(virsh domifaddr ${VM_NAME} | tail -2 | head -1 | awk '{print $4}')
VM_IP=${VM_IP%%/*}
echo "IP of ${VM_NAME} is ${VM_IP}"

message "Checking VM uname"
VM_UNAME="$(ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} uname -n)"

if [ -z "${VM_UNAME}" ]; then
	die "Failed to get uname from ${VM_IP}"
fi

message "VM ${VM_NAME} uname is ${VM_UNAME}"

CHECKFILE=checkmetrics-json-${VM_UNAME}.toml

if [ ! -f "${CONFIG_DIR}/${CHECKFILE}" ]; then
	die "Env file ${CONFIG_DIR}/${CHECKFILE} missing"
fi

message "copying over checkmetrics file"
scp ${SSH_OPTS} "${CONFIG_DIR}/${CHECKFILE}" ${VM_USERNAME}@${VM_IP}:${CHECKFILE}
ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} sudo mkdir /etc/checkmetrics
ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} sudo cp ${CHECKFILE} /etc/checkmetrics/${CHECKFILE}
ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} rm ${CHECKFILE}

message "Shutting down VM ${VM_NAME}"
ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} sudo shutdown now
