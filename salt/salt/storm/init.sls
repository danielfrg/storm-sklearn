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

{{ storm.data_dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

# Supervisord
/var/log/storm:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

storm.conf:
  pkg.installed:
    - name: supervisor
  file.managed:
    - name: /etc/supervisor/conf.d/storm.conf
    - source: salt://storm/files/supervisord.conf
    - template: jinja
    - makedirs: True
    - context:
      storm: {{ storm }}
      java: {{ java }}
    - require:
      - pkg: storm.conf
      - file: /var/log/storm

update-supervisor:
  module.run:
    - name: supervisord.update
    - watch:
      - file: storm.conf
