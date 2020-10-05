{#
# Copyright (c) 2020 Red Hat, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Convert OS name to node label string.
#}
{% if os == "centos8" -%}
centos8_azure
{% elif os == "debian10" -%}
debian10_azure
{% elif os == "fedora32" -%}
fedora32_azure
{% elif os == "opensuse15" -%}
opensuse15-azure
{% elif os == "rhel8" -%}
rhel8_azure
{% elif os == "ubuntu1804" -%}
ubuntu1804_azure
{% elif os == "ubuntu1804_ARM" -%}
arm_node && arm-ubuntu-1804
{% endif %}
