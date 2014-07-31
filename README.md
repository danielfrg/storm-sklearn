storm-sklearn
=============

This is an example project to run a storm topology to run for making
real time classification based on an scikit-learn model.

One of the main differences is that streamparse is not going to create any
virutalenvs on this case salt it's going to use the conda virtualenv
which gives a series of advantages.

This mainly project uses:

- storm (duh)
- salt
- streamparse
- scikit-learn
- conda

## Storm cluster deployment

### salt-master instance

The salt-master is in charge of creating and managing all the other instances.
This is going be the most manual part of the process since it
requires the manual creation and semi-manual bootstraping of that instance.

Create a new instance for the salt-master and bootstrap salt using the
`master_bootstrap.sh` script (`sudo bash master_bootstrap.sh`)
this will clone the repository and install salt-master and salt-minion on that instance.

The remaining bootstraping of the salt-master instance will be done by itself
but it will need:

1. A private key (e.g. `~/.ssh/my_keypair.pem`). tip: use scp
2. Inside `~/storm-sklearn/salt/pillar/`:
    1. copy `aws.template.sls` to `aws.sls` and fill it with the correct values
    2. copy `zookeeper.template.sls` to `zookeeper.sls` and fill it with the correct valuesS
    2. copy `storm.template.sls` to `storm.sls` and fill it with the correct valuesS

`zookeeper.sls` and `storm.sls` example:

```
private_key_path: "/home/ubuntu/.ssh/daniel_keypair.pem"
private_key_name: "daniel_keypair"
security_group: "open"
location: "us-east-1"
availability_zone: "us-east-1d"
```

Now you can bootstrap the salt-master using itself!:
`sudo salt '*' state.highstate` everything should be succesfull.

### zookeeper quorum

Storm needs a zookeeper quorum for coordination.

Create a `zookeeper.map` file in the home directory like this:

```
zookeeper:
  - zookeeper0
  - zookeeper1
  - zookeeper2
```

Create the 3 instances in parallel:
`sudo salt-cloud --map=/home/ubuntu/zookeeper.map --parallel`

Bootstrap zookeeper in the new instances:
`sudo salt 'zookeeper*' state.highstate --state-output=mixed`

### storm cluster

Create the storm nimbus instance:
`sudo salt-cloud -p storm-nimbus storm-nimbus`

Create a `storm.map` file in the home directory

```
storm-supervisor:
  - storm-supervisor0
  - storm-supervisor1
  - storm-supervisor2
```

Workers run the `storm-supervisor` daemon and a conda virutalenv is created
for the python code to run, it also downloads the pickled sklearn models.

Provision all storm instances: `sudo salt 'storm*' state.highstate`

## Submit topology

For now you need my patched version of streamparse that does not create virutalenvs:
https://github.com/danielfrg/streamparse

### Locally

A Vagrantfile is provided with zookeeper, storm-nimbus and storm-supervisor,
just do `vagrant up`.

To submit the topology need execute `vagrant ssh-config` and paste
the output in the ssh config file (`~/.ssh/config`) like:

```
Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/danielfrg/.vagrant.d/insecure_private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

Then you should be able to run `sparse submit -e vagrant`

### In the cloud

Just need to change the `sklearn/config.json` file and add the correct
storm-nimbus host. After that just need to run `sparse submit -e prod`
