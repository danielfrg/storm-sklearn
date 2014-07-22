{%- from 'storm/settings.sls' import storm with context %}
{%- from 'zookeeper/settings.sls' import zk with context %}

include:
  - sun-java
  - sun-java.env

{{ storm.data_dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

install-storm-dist:
  cmd.run:
    - name: curl {{ storm.dl_opts }} '{{ storm.source_url }}' | tar xz
    - cwd: /usr/lib/
    - unless: test -d {{ storm.real_home }}
  alternatives.install:
    - name: storm-home-link
    - link: {{ storm.home }}
    - path: {{ storm.real_home }}
    - priority: 30
    - require:
      - cmd: install-storm-dist

{{ storm.real_home }}/conf/storm.yaml:
  file.managed:
    - source: salt://storm/files/storm.yaml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      zookeepers: {{ zk.zookeepers_with_ids }}
      storm: {{ storm }}
    - require:
      - cmd: install-storm-dist

supervisor:
  pkg.installed

/var/log/storm:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

/etc/supervisor/supervisord-storm.conf:
  file.managed:
    - source: salt://storm/files/supervisord.conf
    - template: jinja
    - context:
      storm: {{ storm }}

supervisord:
  background.running:
    - name: supervisord -c /etc/supervisor/supervisord-storm.conf
    - pid: /var/run/supervisord-storm.pid
    - writepid: False
    - force: False
    - require:
      - pkg: supervisor
      - file: {{ storm.real_home }}/conf/storm.yaml
      - file: /etc/supervisor/supervisord-storm.conf
