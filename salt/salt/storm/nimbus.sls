include:
  - storm

storm-nimbus:
  supervisord.running:
    - conf_file: /etc/supervisord.conf
    - restart: True
    - require:
      - pkg: supervisor
      - file: /etc/supervisord.conf
