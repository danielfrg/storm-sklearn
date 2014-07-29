base:
  'salt-master':
    - salt-master
  'roles:zookeeper':
    - match: grain
    - zookeeper.server
  'roles:storm-nimbus':
    - match: grain
    - storm.nimbus
  'roles:storm-supervisor':
    - match: grain
    - storm.supervisor
    - pythonenv
