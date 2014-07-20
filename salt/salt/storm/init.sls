{%- from 'storm/settings.sls' import storm with context %}
{%- from 'zookeeper/settings.sls' import zk with context %}

include:
  - java

{{ storm.prefix }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

{{ storm.data_dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

unpack-storm-tarball:
  cmd.run:
    - name: curl {{ storm.dl_opts }} '{{ storm.source_url }}' | tar xz --no-same-owner
    - cwd: {{ storm.prefix }}
    - unless: test -d {{ storm.real_home }}
    - require:
      - file: {{ storm.prefix }}
  alternatives.install:
    - name: storm-home-link
    - link: {{ storm.home }}
    - path: {{ storm.real_home }}
    - priority: 30

{{ storm.real_home }}/conf/storm.yaml:
  file.managed:
    - source: salt://zookeeper/conf/zoo.cfg
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      zookeepers: {{ zk.zookeepers_with_ids }}
      storm: {{ storm }}
