include:
  - storm

storm-supervisor:
  supervisord.running:
    - conf_file: /etc/supervisor/supervisord-storm.conf
    - restart: True
    - update: True
    - require:
      - background: supervisord
