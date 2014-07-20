java_home: /usr/lib/jvm/java-7-oracle

zookeeper:
    source_url: 'http://www.us.apache.org/dist/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz'
    version: 3.4.5
    prefix: /usr/lib/zookeeper
    data_dir: /var/lib/zookeeper/data
    port: 2181
    uid: 6030
    bind_address: 0.0.0.0

    # Instance settings
    private_key_path: ""
    private_key_name: ""
    security_group: ""
    location: ""
    availability_zone: ""
