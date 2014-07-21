include:
  - storm

/var/log/storm:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

storm-nimbus:
  supervisord.running:
    - conf_file: /etc/supervisor/supervisord-storm.conf
    - restart: True
    - update: True
    - require:
      - pkg: supervisor
      - file: /etc/supervisor/supervisord-storm.conf

storm-ui:
  supervisord.running:
    - conf_file: /etc/supervisor/supervisord-storm.conf
    - restart: True
    - update: True
    - require:
      - pkg: supervisor
      - file: /etc/supervisor/supervisord-storm.conf
