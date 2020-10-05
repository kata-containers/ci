#!/bin/bash
#
# Copyright (c) 2020 Red Hat, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# Use this script to publish the jobs on Jenkins.
#
set -e

script_dir="$(realpath $(dirname $0))"
jobs_dir="$script_dir/jobs"

function usage
{
	cat <<-EOF
		Usage: $0 <config file>
	EOF
	exit 1
}

config_file=$1
[ -n "$config_file" ] || usage

readonly cmd="jenkins-jobs"
command -V "$cmd" || echo "Needs $cmd command"

# Let's first test it can generate the jobs.
$cmd test "$jobs_dir"
if [ "$?" -ne 0 ]; then
	echo "Failed to generate jobs"
	exit 1
fi

# Going to update with all jobs.
$cmd --conf "$config_file" update "$jobs_dir"
