{% from "kubernetes/map.jinja" import kubernetes_settings with context %}
{% set base_url = kubernetes_settings.install.base_url + "/v" + kubernetes_settings.version + "/bin/linux/amd64" %}

include:
  - docker
  - kubernetes.ssl
  - kubernetes.common
  - kubernetes.weave

kubernetes-api-download:
  cmd.run:
    - name: curl -L -s {{ base_url }}/kube-apiserver -o kube-apiserver
    - cwd: {{ kubernetes_settings.bin_directory }}
    - unless: test -f {{ kubernetes_settings.bin_directory }}/kube-apiserver
    - require_in:
        file: {{ kubernetes_settings.bin_directory }}/kube-apiserver

kubernetes-apiserver:
  file.managed:
    - name: {{ kubernetes_settings.bin_directory }}/kube-apiserver
    - mode: 0755

kubernetes-controller-download:
  cmd.run:
    - name: curl -L -s {{ base_url }}/kube-controller-manager -o kube-controller-manager
    - cwd: {{ kubernetes_settings.bin_directory }}
    - unless: test -f {{ kubernetes_settings.bin_directory }}/kube-controller-manager
    - require_in:
        file: {{ kubernetes_settings.bin_directory }}/kube-controller-manager

kubernetes-controller:
  file.managed:
    - name: {{ kubernetes_settings.bin_directory }}/kube-controller-manager
    - mode: 0755

kubernetes-scheduler-download:
  cmd.run:
    - name: curl -L -s {{ base_url }}/kube-scheduler -o kube-scheduler
    - cwd: {{ kubernetes_settings.bin_directory }}
    - unless: test -f {{ kubernetes_settings.bin_directory }}/kube-scheduler
    - require_in:
        file: {{ kubernetes_settings.bin_directory }}/kube-scheduler

kubernetes-scheduler:
  file.managed:
    - name: {{ kubernetes_settings.bin_directory }}/kube-scheduler
    - mode: 0755

### Config
kubernetes-authn-file:
  file.managed:
    - name: {{ kubernetes_settings.config_directory }}/token.csv
    - source: salt://kubernetes/files/token.csv.jinja
    - user: root
    - group: root
    - mode: 0400
    - template: jinja
    - watch_in:
        service: kubernetes-api-service

kubernetes-authz-file:
  file.managed:
    - name: {{ kubernetes_settings.config_directory }}/authorization-policy.jsonl
    - source: salt://kubernetes/files/authorization-policy.jsonl.jinja
    - user: root
    - group: root
    - mode: 0400
    - template: jinja
    - watch_in:
        service: kubernetes-api-service

### Service
kubernetes-api-systemd-file:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://kubernetes/files/kube-apiserver.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: kube-apiserver

kubernetes-api-service:
  service.running:
    - name: kube-apiserver
    - enable: True

kubernetes-controller-systemd-file:
  file.managed:
    - name: /etc/systemd/system/kube-controller-manager.service
    - source: salt://kubernetes/files/kube-controller-manager.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: kube-controller-manager

kubernetes-controller-service:
  service.running:
    - name: kube-controller-manager
    - enable: True

kubernetes-scheduler-systemd-file:
  file.managed:
    - name: /etc/systemd/system/kube-scheduler.service
    - source: salt://kubernetes/files/kube-scheduler.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: kube-scheduler

kubernetes-scheduler-service:
  service.running:
    - name: kube-scheduler
    - enable: True

kubernetes-create-addons-systemd-file:
  file.managed:
    - name: /etc/systemd/system/kube-create-addons.service
    - source: salt://kubernetes/files/kube-create-addons.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: kube-create-addons

kubernetes-create-addons-service:
  service.running:
    - name: kube-create-addons
    - enable: True

kubernetes-kubeconfig:
  file.managed:
    - name: {{ kubernetes_settings.config_directory }}/kubeconfig
    - source: salt://kubernetes/files/kubeconfig.jinja
    - user: root
    - group: root
    - mode: 0444
    - template: jinja
