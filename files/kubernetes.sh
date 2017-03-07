{%- from "kubernetes/map.jinja" import kubernetes_settings with context %}
#!/usr/bin/env bash

export PATH="$PATH:{{ kubernetes_settings.bin_directory }}"
