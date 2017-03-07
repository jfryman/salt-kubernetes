{% from "kubernetes/map.jinja" import kubernetes_settings with context %}

kubernetes-ssl-directory:
  file.directory:
    - name: {{ kubernetes_settings.ssl_directory }}
    - makedirs: True

kubernetes-ssl-cert-file:
  file.managed:
    - name: {{ kubernetes_settings.ssl_directory }}/kubernetes.crt
    - source: salt://certificates/kubernetes/{{ kubernetes_settings.name }}/kubernetes.crt
    - user: root
    - group: root
    - mode: 0400

kubernetes-ssl-key-file:
  file.managed:
    - name: {{ kubernetes_settings.ssl_directory }}/kubernetes.key
    - source: salt://certificates/kubernetes/{{ kubernetes_settings.name }}/kubernetes.key
    - user: root
    - group: root
    - mode: 0400

kubernetes-ssl-ca-file:
  file.managed:
    - name: {{ kubernetes_settings.ssl_directory }}/ca.crt
    - source: salt://certificates/kubernetes/{{ kubernetes_settings.name }}/ca.crt
    - user: root
    - group: root
    - mode: 0400
