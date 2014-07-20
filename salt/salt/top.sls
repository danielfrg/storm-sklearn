base:
  'salt-master':
    - salt-master
  'roles:zookeeper':
    - match: grain
    - zookeeper.server
  'roles:storm-nimbus':
    - match: grain
    - storm
