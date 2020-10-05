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
readonly cmd="jenkins-jobs"
test_only=0
config_file=""

function die
{
	local msg="$*"
	echo "ERROR: $msg" >&2
	exit 1
}

function usage
{
	cat <<-EOF
	This script uses the Jenkins Job Builder to manage the Kata Containers
	CI jobs on Jenkins.

	It needs the jenkins-jobs command installed as well as a configuration
	file that contains information about how to access the Jenkins
	instance. See the README.md for further details.

	Usage $0: -c CONFIG [-t] [-h], where:
	  -c           Path to the configuration file.
	  -h           Print this message.
	  -t           Do not publish jobs, only test they can be generated.
	EOF
}

function parse_args
{
	while getopts "c:ht" opt; do
		case ${opt} in
			c) config_file="${OPTARG}" ;;
			h) usage; exit 0 ;;
			t) test_only=1 ;;
			*) usage; exit 1 ;;
		esac
	done

	if [ -z "$config_file" ]; then
		usage
		die "missing the config file"
	fi
}

function main
{
	parse_args "$@"
	command -v "$cmd" || die "$cmd command is needed"

	# First test it can generate the jobs.
	$cmd test "$jobs_dir" || die "some jobs cannot be generated"

	if [ $test_only -eq 0 ]; then
		# Going to update the managed jobs.
		$cmd --conf "$config_file" update "$jobs_dir"
	fi
}

main "$@"
