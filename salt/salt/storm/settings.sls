{% set p  = salt['pillar.get']('storm', {}) %}

{%- set source_url     = p.get('source_url') %}
{%- set version_name   = p.get('version_name') %}
{%- set dl_opts        = p.get('dl_opts', '-L') %}
{%- set home           = p.get('home') %}
{%- set data_dir       = p.get('data_dir') %}
{%- set real_home      = '/usr/lib/' + version_name %}

{%- set force_mine_update = salt['mine.send']('network.get_hostname') %}
{%- set nimbus_hosts_dict = salt['mine.get']('roles:storm-nimbus', 'network.get_hostname', 'grain') %}
{%- set nimbus_hosts = nimbus_hosts_dict.values() %}
{%- set nimbus_hosts_num  = nimbus_hosts_dict.keys() | length() %}
{%- set nimbus_host = '' %}

{%- if nimbus_hosts_num > 0 %}
{%- set nimbus_host = nimbus_hosts | first() %}
{%- endif %}

{%- set storm = {} %}
{%- do storm.update( {'version_name'    : version_name,
                      'source_url'      : source_url,
                      'dl_opts'         : dl_opts,
                      'home'            : home,
                      'real_home'       : real_home,
                      'data_dir'        : data_dir,
                      'nimbus_host'     : nimbus_host,
                    }) %}
