include:
  - storm

storm-supervisor:
  supervisord.running:
    - name: supervisor
    - conf_file: /etc/supervisor/storm/supervisord.conf
    - require:
      - cmd: supervisord
      - file: /etc/supervisor/storm/supervisord.conf
