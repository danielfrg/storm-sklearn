python-pip:
  pkg.installed

apache-libcloud:
  pip.installed:
    - upgrade: True
    - require:
      - pkg: python-pip

requests:
  pip.installed:
    - upgrade: True
    - require:
      - pkg: python-pip

# Salt cloud files
/etc/salt/cloud.providers:
  file.managed:
    - source: salt://salt-master/files/cloud.providers
    - user: root
    - template: jinja

/etc/salt/cloud.profiles:
  file.managed:
    - source: salt://salt-master/files/cloud.profiles
    - user: root
    - template: jinja
