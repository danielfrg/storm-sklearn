include:
  - storm

storm-nimbus:
  supervisord.running:
    - name: nimbus
    - conf_file: /etc/supervisor/storm/supervisord.conf
    - require:
      - cmd: supervisord
      - file: /etc/supervisor/storm/supervisord.conf

storm-ui:
  supervisord.running:
    - name: ui
    - conf_file: /etc/supervisor/storm/supervisord.conf
    - require:
      - cmd: supervisord
      - file: /etc/supervisor/storm/supervisord.conf
