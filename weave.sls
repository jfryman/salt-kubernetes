{% from "kubernetes/map.jinja" import kubernetes_settings with context %}
{% set url = kubernetes_settings.weave.base_url + "/v" + kubernetes_settings.weave.version + "/weave" %}

weave-bin-directory:
  file.directory:
    - name: {{ kubernetes_settings.weave.bin_directory }}
    - makedirs: True

weave-download:
  file.managed:
    - name: {{ kubernetes_settings.weave.bin_directory }}/weave
    - source: {{ url }}
    - skip_verify: true
    - mode: 0755
    - unless: test -f {{ kubernetes_settings.weave.bin_directory }}/weave

weave-setup:
  cmd.wait:
    - name: {{ kubernetes_settings.weave.bin_directory }}/weave setup
    - watch:
      - file: {{ kubernetes_settings.weave.bin_directory }}/weave
    - require_in:
      - service: weave

weave-settings-file:
  file.managed:
    - name: /etc/default/weave
    - source: salt://kubernetes/files/weave.env.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: weave

weave-path:
  file.managed:
    - name: /etc/profile.d/weave.sh
    - source: salt://kubernetes/files/weave.sh
    - mode: 0755
    - user: root
    - group: root
    - template: jinja

weave-systemd-file:
  file.managed:
    - name: /etc/systemd/system/weave.service
    - source: salt://kubernetes/files/weave.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: weave

weave-service:
  service.running:
    - name: weave
    - enable: True

weave-expose-systemd-file:
  file.managed:
    - name: /etc/systemd/system/weave-expose.service
    - source: salt://kubernetes/files/weave-expose.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: weave-expose

weave-expose-service:
  service.running:
    - name: weave-expose
    - enable: True
