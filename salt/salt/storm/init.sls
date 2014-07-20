{%- from 'storm/settings.sls' import storm with context %}

include:
  - storm

{{ storm.prefix }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

unpack-storm-tarball:
  cmd.run:
    - name: curl {{ storm.dl_opts }} '{{ storm.source_url }}' | tar xz --no-same-owner
    - cwd: {{ storm.prefix }}
    - unless: test -d {{ storm.storm_real_home }}
    - require:
      - file: {{ storm.prefix }}
  alternatives.install:
    - name: storm-home-link
    - link: {{ storm.home }}
    - path: {{ storm.storm_real_home }}
    - priority: 30
