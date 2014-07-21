include:
  - storm

storm-nimbus:
  supervisord.running:
    - conf_file: /etc/supervisord.conf
    - require:
      - pkg: supervisor
      - file: /etc/supervisord.conf
