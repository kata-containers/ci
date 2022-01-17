{#
# Copyright (c) 2020 Red Hat, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Convert OS name to node label string.
#}
{%- if os == "centos8" -%}
centos8_azure
{%- elif os == "fedora35" -%}
fedora35_azure
{%- elif os == "ubuntu1804" -%}
ubuntu1804_azure || ubuntu1804-azure
{%- elif os == "ubuntu-20.04" -%}
ubuntu_20.04
{%- elif os == "ubuntu-20.04-ARM" -%}
arm_node || arm-ubuntu-2004
{%- endif %}
