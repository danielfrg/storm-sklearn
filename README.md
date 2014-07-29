storm-sklearn
=============

From zero to storm cluster for realtime classification using scikit-learn
using:

- storm (duh)
- salt
- streamparse
- conda

## Deployment

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


Create a `storm.map` file in the home directory

```
workers:
```

Workers run the `storm-supervisor` daemon and a conda virutalenv is created
for the python code to run.

## Submit topology

The sklearn streamparse project in this repo is a simple example on how to run
scikit-learn inside a topology.

The main difference is that streamparse is not going to create a virutalenv
for the python code it's going to use the conda virtualenv created using salt
