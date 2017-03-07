{% from "kubernetes/map.jinja" import kubernetes_settings with context %}
{% set url = kubernetes_settings.cni.base_url + "/v" + kubernetes_settings.cni.version + "/cni-v" + kubernetes_settings.cni.version + ".tgz" %}
{% set bin_directory = kubernetes_settings.cni.base_directory + "/bin" %}

cni-bin-directory:
  file.directory:
    - name: {{ bin_directory }}
    - makedirs: True

cni-conf-directory:
  file.directory:
    - name: /etc/cni/net.d
    - makedirs: True

cni-download:
  file.managed:
    - name: {{ kubernetes_settings.cni.base_directory }}/cni.tgz
    - source: {{ url }}
    - skip_verify: true
    - unless: test -f {{ bin_directory }}/cnitool

cni-extract:
  cmd.wait:
    - name: sudo tar -xvf cni.tgz -C {{ bin_directory }}
    - cwd: {{ kubernetes_settings.cni.base_directory }}
    - unless: test -f {{ bin_directory }}/cnitool
    - watch:
        - file: cni-download

cni-path:
  file.managed:
    - name: /etc/profile.d/cni.sh
    - source: salt://kubernetes/files/cni.sh
    - mode: 0755
    - user: root
    - group: root
    - template: jinja
