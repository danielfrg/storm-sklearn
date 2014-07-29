from __future__ import absolute_import, print_function, unicode_literals

import re
from tempfile import NamedTemporaryFile

from invoke import task, run
from streamparse.ext.invoke import prepare_topology, _kill_topology, \
                                   is_safe_to_submit, jar_for_deploy
from streamparse.ext.util import get_env_config, get_topology_definition, \
                                 get_nimbus_for_env_config, get_config

@task
def submit_topology(name=None, env_name="prod", par=2, options=None,
                    force=False, debug=False):
    """Submit a topology to a remote Storm cluster."""
    prepare_topology()

    config = get_config()
    name, topology_file = get_topology_definition(name)
    env_name, env_config = get_env_config(env_name)
    host, port = get_nimbus_for_env_config(env_config)

    # TODO: Super hacky way to replace "python" with our venv executable, need
    # to fix this
    with open(topology_file, "r") as fp:
        contents = fp.read()
    contents = re.sub(r'"python"',
                     '"{}/{}/bin/python"'
                      .format(env_config["virtualenv_root"], name),
                      contents)
    tmpfile = NamedTemporaryFile(dir=config["topology_specs"])
    tmpfile.write(contents)
    tmpfile.flush()
    print("Created modified topology definition file {}.".format(tmpfile.name))

    # replaced with /path/to/venv/bin/python instead

    # Prepare a JAR that doesn't have Storm dependencies packaged
    topology_jar = jar_for_deploy()

    print('Deploying "{}" topology...'.format(name))
    with ssh_tunnel(env_config["user"], host, 6627, port):
        print("ssh tunnel to Nimbus {}:{} established."
              .format(host, port))

        if force and not is_safe_to_submit(name):
            print("Killing current \"{}\" topology.".format(name))
            _kill_topology(name, run_kwargs={"hide": "both"})
            while not is_safe_to_submit(name):
                print("Waiting for topology {} to quit...".format(name))
                time.sleep(0.5)

            print("Killed.")

        jvm_opts = [
            "-Dstorm.jar={}".format(topology_jar),
            "-Dstorm.options=",
            "-Dstorm.conf.file=",
        ]
        os.environ["JVM_OPTS"] = " ".join(jvm_opts)
        cmd = ["lein",
               "run -m streamparse.commands.submit_topology/-main",
               tmpfile.name]
        if debug:
            cmd.append("--debug")
        cmd.append('--option "topology.workers={}"'.format(par))
        cmd.append('--option "topology.acker.executors={}"'.format(par))
        if options is None:
            options = []
        for option in options:
            cmd.append('--option {}'.format(option))
        full_cmd = " ".join(cmd)
        print("Running lein command to submit topology to nimbus:")
        print(full_cmd)
        run(full_cmd)

    tmpfile.close()
