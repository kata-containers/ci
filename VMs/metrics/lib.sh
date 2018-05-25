#!/bin/bash
# Copyright (c) 2018 Intel Corporation
# 
# SPDX-License-Identifier: Apache-2.0

die() {
	echo "Fatal: $*" >&2
	exit 1
}

error() {
	echo "Error: $*" >&2
}

message() {
	echo "Message: $*"
}
