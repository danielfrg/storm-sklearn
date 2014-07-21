include:
  - storm

storm-nimbus:
  supervisord.running:
    - conf_file: /etc/supervisord.conf
    - restart: True
    - update: True
    - require:
      - pkg: supervisor
      - file: /etc/supervisord.conf

storm-ui:
  supervisord.running:
    - conf_file: /etc/supervisord.conf
    - restart: True
    - update: True
    - require:
      - pkg: supervisor
      - file: /etc/supervisord.conf
