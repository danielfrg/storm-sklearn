base:
  'salt-master':
    - salt-master
  'roles:zookeeper':
    - match: grain
    - zookeeper.server
    - zookeeper.debug
  'roles:storm-nimbus':
    - match: grain
    - storm.nimbus
  'roles:storm-supervisor':
    - match: grain
    - storm.supervisor
