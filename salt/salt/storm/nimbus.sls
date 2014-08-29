include:
  - storm

storm-nimbus:
  supervisord.running:
    - name: nimbus
    - require:
      - sls: storm

storm-ui:
  supervisord.running:
    - name: ui
    - require:
      - sls: storm
