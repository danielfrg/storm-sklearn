include:
  - storm

storm-nimbus:
  supervisord.running:
    - conf_file: /etc/supervisor/supervisord-storm.conf
    - restart: True
    - update: True
    - require:
      - background: supervisord

storm-ui:
  supervisord.running:
    - conf_file: /etc/supervisor/supervisord-storm.conf
    - restart: True
    - update: True
    - require:
      - background: supervisord
