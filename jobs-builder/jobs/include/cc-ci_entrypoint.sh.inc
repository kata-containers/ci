#!/bin/bash
#
# Copyright (c) 2022 Red Hat, Inc.
# SPDX-License-Identifier: Apache-2.0
#
{# Wrapper shell script to call kata-containers/tests/.ci/ci_entry_point.sh
   with expected environment variables exported.
   This is a jinja2 template.
#}

set -e
set -x

curl -OL https://raw.githubusercontent.com/kata-containers/tests/CCv0/.ci/ci_entry_point.sh
export DEBUG=true
export CI_JOB="{{ ci_job }}"
bash -x ci_entry_point.sh "$GIT_URL"
