git:
  pkg.installed

repository:
  git.latest:
    - name: {{ pillar['git']['repo'] }}
    - target: /home/ubuntu/storm-sklearn
    - rev: master
    - force_checkout: True
    - user: ubuntu
    - require:
      - pkg: git

# Salt cloud
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
