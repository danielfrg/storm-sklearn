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

supervisor:
  pkg.installed

/etc/supervisord.conf:
  file.managed:
    - source: salt://storm/files/supervisord.conf
    - template: jinja
    - context:
      storm: {{ storm }}

supervisord:
  background.running:
    - name: supervisord -c /etc/supervisord.conf
    - pid: /var/run/supervisord.pid
    - writepid: False
    - force: False
    - require:
      - file: /etc/supervisord.conf
      - pkg: supervisor
