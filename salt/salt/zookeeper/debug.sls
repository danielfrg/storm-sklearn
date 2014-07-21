{%- from 'zookeeper/settings.sls' import zk with context %}
{%- from 'zookeeper/settings.sls' import zookeepers_host_dict with context %}

/tmp/zookeeper.debug:
  file.managed:
    - contents: |
        Hosts
    {%- for k,v in zookeepers_host_dict.items() %}
        {{ k }} => {{ v }}
    {%- endfor %}
        -----
        Variables
    {%- for k,v in zk.items() %}
        {{ k }} => {{ v }}
    {%- endfor %}
