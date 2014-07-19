#!/bin/bash

# Install salt
curl -o install_salt.sh -L https://bootstrap.saltstack.com
sh install_salt.sh -M -L -P -p salt-cloud # -M: master, -L and -P: Apache libcloud

# Clone repo
su ubuntu <<'EOF'
cd ~
git clone https://github.com/danielfrg/storm-sklearn.git
exit 0
EOF

# Master config
bash -c 'cat <<EOF > /etc/salt/master
auto_accept: True

file_roots:
  base:
    - /home/ubuntu/storm-sklearn/salt/salt

pillar_roots:
  base:
    - /home/ubuntu/storm-sklearn/salt/pillar
EOF'

# Minion config
bash -c 'cat <<EOF > /etc/salt/minion
master: localhost
id: salt-master
EOF'

service salt-minion restart
service salt-master restart
