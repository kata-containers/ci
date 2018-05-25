#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

source global_env.sh
source lib.sh

check_configs() {
	message "Cheking config dir ${CONFIG_DIR}"

	if [ $(arch) != "x86_64" ]; then
		die "Architecture [$(arch)] not supported yet - user-env files will need modifications"
	fi

	if [ ! -f "${CONFIG_DIR}/${ENV_FILE}" ]; then
		die "Env file ${CONFIG_DIR}/${ENV_FILE} missing"
	fi

	if [ ! -f "${CONFIG_DIR}/${META_DATA_NAME}" ]; then
		die "Meta data file ${CONFIG_DIR}/${META_DATA_NAME} missing"
	fi

	if [ ! -f "${CONFIG_DIR}/${USER_DATA_NAME}" ]; then
		die "User data file ${CONFIG_DIR}/${USER_DATA_NAME} missing"
	fi

	message "Sourcing the env file"
	source "${CONFIG_DIR}/${ENV_FILE}"

	# Default us to a Linux VM
	VM_TYPE="${VM_TYPE:-Linux}"

	IMG_NAME=${IMG_DIR}/${VM_NAME}.img
	ISOFILENAME=${IMG_DIR}/${VM_NAME}_config.iso
}

check_keys() {
	if [ ! -f ${PRIVKEYNAME} ]; then
		die "Private key file ${PRIVKEYNAME} not present"
	fi

	if [ ! -f ${PUBKEYNAME} ]; then
		die "Public key file ${PUBKEYNAME} not present"
	fi

	PUBLICKEYCONTENTS=$(cat ${PUBKEYNAME})
	# Escape any special regex chars in the key for later use with sed
        ESCAPEDPUBLICKEYCONTENTS=$(echo "${PUBLICKEYCONTENTS}" | sed -e 's/\([[\/.*]\|\]\)/\\&/g')
}

create_initfiles() {
	message "Removing any old configs"
	rm -f ./${META_DATA_NAME}
	rm -f ./${USER_DATA_NAME}

	message "Copying new configs"
	cp "${CONFIG_DIR}/${META_DATA_NAME}" ./${META_DATA_NAME}
	cp "${CONFIG_DIR}/${USER_DATA_NAME}" ./${USER_DATA_NAME}

	message "Massaging configs"
	# Warning - we may need to escape the key to stop it pattern matching!
	sed -i "s/PUBLICKEYCONTENTS/${ESCAPEDPUBLICKEYCONTENTS}/g" ./${META_DATA_NAME}
	sed -i "s/VMNAME/${VM_NAME}/g" ./${META_DATA_NAME}

	sed -i "s/PUBLICKEYCONTENTS/${ESCAPEDPUBLICKEYCONTENTS}/g" ./${USER_DATA_NAME}
	sed -i "s/USERNAME/${VM_USERNAME}/g" ./${USER_DATA_NAME}
	MYARCH=$(go env GOARCH)
	sed -i "s/ARCH/${MYARCH}/g" ./${USER_DATA_NAME}
}

create_iso() {
	message "Creating cloud init ISO image"

	rm -f ${ISOFILENAME}
	genisoimage -o ${ISOFILENAME} -V cidata -r -J meta-data user-data
}

run_cloud_init() {
	message "Running cloud init VM boot"

	# first, clean up any pre-existing domain
	message "Destroying any existing VM/image"
	virsh stop ${VM_NAME}
	virsh destroy ${VM_NAME}
	virsh undefine ${VM_NAME}

	message "Destroying any existing VM/image clones"
	virsh stop ${VM_CLONE_NAME}
	virsh destroy ${VM_CLONE_NAME}
	virsh undefine ${VM_CLONE_NAME}

	# Drop any old img, and get a fresh bare cloud image to build upon
	rm -f ${IMG_NAME}

	if [ ! -f ${IMG_BASE} ]; then
		message "Trying to fetch base image from $IMG_BASE_SOURCE"
		wget ${IMG_BASE_SOURCE} -O ${IMG_BASE} --progress=dot:giga
	fi

	cp ${IMG_BASE} ${IMG_NAME}
	message "Resizing image copy"
	qemu-img resize ${IMG_NAME} ${VM_IMAGE_SIZE}G

	# add the existing simple qcow2 image file to virsh
	message "Creating VM master image"
	virt-install \
 	-n ${VM_NAME} \
 	--description "simple test" \
 	--os-type=${VM_TYPE} \
 	--os-variant=${VM_VARIANT} \
 	--cpu=host \
 	--ram=${VM_RAM_SIZE} \
 	--vcpus=${VM_VCPUS} \
 	--disk path=${IMG_NAME},bus=virtio,size=${VM_IMAGE_SIZE} \
 	--disk path=${ISOFILENAME},device=cdrom \
 	--graphics none \
 	--console pty,target_type=serial \
 	--import \
 	--boot useserial=on
}

main() {
	# Have to check keys first, as we use the data in the config create
	check_keys
	check_configs
	create_initfiles
	create_iso
	run_cloud_init
}

if [ $# != 1 ]; then
	error "Missing first argument"
	die "Usage: $0 distro_config_dirname"
fi

CONFIG_DIR="$1"

main
