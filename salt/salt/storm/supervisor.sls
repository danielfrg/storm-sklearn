include:
  - storm

storm-supervisor:
  supervisord.running:
    - name: supervisor
    - require:
      - sls: storm
