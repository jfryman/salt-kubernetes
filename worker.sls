{% from "kubernetes/map.jinja" import kubernetes_settings with context %}
{% set base_url = kubernetes_settings.install.base_url + "/v" + kubernetes_settings.version + "/bin/linux/amd64" %}

include:
  - docker
  - kubernetes.ssl
  - kubernetes.common
  - kubernetes.cni
  - kubernetes.weave

socat:
  pkg.installed

kubernetes-proxy-download:
  cmd.run:
    - name: curl -L -s {{ base_url }}/kube-proxy -o kube-proxy
    - cwd: {{ kubernetes_settings.bin_directory }}
    - unless: test -f {{ kubernetes_settings.bin_directory }}/kube-proxy
    - require_in:
        file: {{ kubernetes_settings.bin_directory }}/kube-proxy

kubernetes-proxy:
  file.managed:
    - name: {{ kubernetes_settings.bin_directory }}/kube-proxy
    - mode: 0755

kubernetes-kubelet-download:
  cmd.run:
    - name: curl -L -s {{ base_url }}/kubelet -o kubelet
    - cwd: {{ kubernetes_settings.bin_directory }}
    - unless: test -f {{ kubernetes_settings.bin_directory }}/kubelet
    - require_in:
        file: {{ kubernetes_settings.bin_directory }}/kubelet

kubernetes-kubelet:
  file.managed:
    - name: {{ kubernetes_settings.bin_directory }}/kubelet
    - mode: 0755

### Config
kubernetes-kubelet-config-directory:
  file.directory:
    - name: {{ kubernetes_settings.kubelet.config_directory }}
    - user: root
    - group: root
    - mode: 0755

kubernetes-kubeconfig:
  file.managed:
    - name: {{ kubernetes_settings.kubelet.config_directory }}/kubeconfig
    - source: salt://kubernetes/files/kubeconfig.jinja
    - user: root
    - group: root
    - mode: 0444
    - template: jinja
    - watch_in:
        - service: kubelet
        - service: kube-proxy

### Service
kubelet-service:
  file.managed:
    - name: /etc/systemd/system/kubelet.service
    - source: salt://kubernetes/files/kubelet.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: kubelet

kubernetes-kubelet-service:
  service.running:
    - name: kubelet
    - enable: True

kubernetes-proxy-systemd-file:
  file.managed:
    - name: /etc/systemd/system/kube-proxy.service
    - source: salt://kubernetes/files/kube-proxy.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: kube-proxy

kubernetes-proxy-service:
  service.running:
    - name: kube-proxy
    - enable: True
