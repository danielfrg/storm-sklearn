{%- from 'storm/settings.sls' import storm with context %}
{%- from 'zookeeper/settings.sls' import zk with context %}
{%- from 'sun-java/settings.sls' import java with context %}

include:
  - sun-java
  - sun-java.env

install-storm:
  cmd.run:
    - name: curl {{ storm.dl_opts }} '{{ storm.source_url }}' | tar xz
    - cwd: /usr/lib/
    - unless: test -d {{ storm.real_home }}
    - require:
      - alternatives: unpack-jdk-tarball
  alternatives.install:
    - name: storm-home-link
    - link: {{ storm.home }}
    - path: {{ storm.real_home }}
    - priority: 30
    - require:
      - cmd: install-storm
  file.managed:
    - name: {{ storm.real_home }}/conf/storm.yaml
    - source: salt://storm/files/storm.yaml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      zookeepers: {{ zk.zookeepers_with_ids }}
      storm: {{ storm }}
    - require:
      - alternatives: install-storm

supervisor:
  pkg.installed

{{ storm.data_dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

/var/log/supervisor/storm:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

/etc/supervisor/storm/supervisord.conf:
  file.managed:
    - source: salt://storm/files/supervisord.conf
    - makedirs: True
    - template: jinja
    - context:
      storm: {{ storm }}
      java: {{ java }}

supervisord:
  cmd.run:
    - name: supervisord -c /etc/supervisor/storm/supervisord.conf
    - unless: test -e /var/run/supervisord-storm.pid
    - require:
      - pkg: supervisor
      - file: install-storm
      - file: {{ storm.data_dir }}
      - file: /var/log/supervisor/storm
      - file: /etc/supervisor/storm/supervisord.conf
