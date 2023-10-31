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
# Ubuntu 22.04 comes with docker community edition that we don't want to
# use.
sudo apt-get remove -y docker-ce docker-ce-cli containerd.io || true
sudo apt autoremove -y
cd tests/e2e
export PATH="$PATH:/usr/local/bin"
./run-local.sh -r "{{ runtimeclass }}" {%+ if baremetal == "true" %}-u{% endif %}

