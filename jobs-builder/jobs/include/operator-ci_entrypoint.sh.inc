#!/bin/bash
#
# Copyright (c) 2023 Red Hat, Inc.
# SPDX-License-Identifier: Apache-2.0
#
{# Run the Operator CI tests.
   This is a jinja2 template.
#}

sudo apt-get update -y
sudo apt-get install -y ansible python-is-python3
cd tests/e2e
export PATH="$PATH:/usr/local/bin"
./run-local.sh -r "{{ runtimeclass }}" {%+ if baremetal == "true" %}-u{% endif %}

