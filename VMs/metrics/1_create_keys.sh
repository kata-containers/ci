#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

set -x

source global_env.sh

rm -f ${PRIVKEYNAME} ${PUBKEYNAME}
ssh-keygen -t rsa -b 4096 -C "For virsh jenkins" -N "" -f ${PRIVKEYNAME}
