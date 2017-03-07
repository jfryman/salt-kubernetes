{% from "kubernetes/map.jinja" import kubernetes_settings with context %}
{% set base_url = kubernetes_settings.install.base_url + "/v" + kubernetes_settings.version + "/bin/linux/amd64" %}

### Install
kubernetes-bin-directory:
  file.directory:
    - name: {{ kubernetes_settings.bin_directory }}
    - makedirs: True

kubernetes-config-directory:
  file.directory:
    - name: {{ kubernetes_settings.config_directory }}
    - makedirs: True

kubernetes-addons-directory:
  file.directory:
    - name: {{ kubernetes_settings.addons_directory }}
    - makedirs: True

kubernetes-kubectl-download:
  cmd.run:
    - name: curl -L -s {{ base_url }}/kubectl -o kubectl
    - cwd: {{ kubernetes_settings.bin_directory }}
    - unless: test -f {{ kubernetes_settings.bin_directory }}/kubectl
    - require_in:
        file: {{ kubernetes_settings.bin_directory }}/kubectl

kubernetes-kubectl:
  file.managed:
    - name: {{ kubernetes_settings.bin_directory }}/kubectl
    - mode: 0755

kubernetes-path:
  file.managed:
    - name: /etc/profile.d/kubernetes.sh
    - source: salt://kubernetes/files/kubernetes.sh
    - mode: 0755
    - user: root
    - group: root
    - template: jinja
