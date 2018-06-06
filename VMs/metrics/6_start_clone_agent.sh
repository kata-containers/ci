#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

JARSRC="${HOME}/bin/agent.jar"
JARDEST_DIR="/var/lib/jenkins"
JARDEST="${JARDEST_DIR}/agent.jar"

LOGFILE=/dev/null

source global_env.sh
source lib.sh

main()
{
	if [ ! -f "${CONFIG_DIR}/${ENV_FILE}" ]; then
		die "Env file ${CONFIG_DIR}/${ENV_FILE} missing"
	fi

	source "${CONFIG_DIR}/${ENV_FILE}"

	# Ensure we do not have an existing instance
	message "Ensuring ${CONFIG_DIR} is shut down"
	./7_delete_clone.sh "${CONFIG_DIR}"

	# And make the clone
	message "Cloning ${VM_NAME} -> ${VM_CLONE_NAME}"
	./4_clone_vm.sh "${CONFIG_DIR}"

	# And kick it off
	message "Starting clone VM $VM_CLONE_NAME"
	virsh start ${VM_CLONE_NAME}

	message "Napping for ${VM_BOOTTIME}s for VM to come up"
	sleep ${VM_BOOTTIME}

	VM_IP=$(virsh domifaddr ${VM_CLONE_NAME} | tail -2 | head -1 | awk '{print $4}')
	VM_IP=${VM_IP%%/*}

	echo "IP of ${VM_CLONE_NAME} is ${VM_IP}"

	ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} sudo mkdir -p ${JARDEST_DIR}
	ssh ${SSH_OPTS} ${VM_USERNAME}@${VM_IP} sudo chown jenkins ${JARDEST_DIR}
	scp ${SSH_OPTS} ${JARSRC} ${VM_USERNAME}@${VM_IP}:${JARDEST}
}

if [ $# != 1 ]; then
	error "Missing first argument"
	die "Usage: $0 distro_config_dirname"
fi

CONFIG_DIR="$1"

# We are not allowed to generate any output or consume anything from stdin or
# the jenkins master will fail its comms with the agent.jar, and the launch will
# fail.
main $* 2>&1 > ${LOGFILE} < /dev/null

# And finally run the agent
# Note - we may want to try and auto-inject any proxy settings into here...
ssh -F /dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ${PRIVKEYNAME} ${VM_USERNAME}@${VM_IP} java -jar $JARDEST

