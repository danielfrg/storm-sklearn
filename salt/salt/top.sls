base:
  'salt-master':
    - salt-master
  'G@roles:zookeeper':
    - match: grain
    - zookeeper.server
