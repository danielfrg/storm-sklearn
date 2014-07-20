base:
  'salt-master':
    - salt-master
  'roles:zookeeper':
    - match: grain
    - zookeeper.server
