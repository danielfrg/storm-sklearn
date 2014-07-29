import os


def execcmd(cmd, user=None):
    return __salt__['cmd.run_all'](' '.join(cmd), runas=user)


def create_conda_cmd(conda, conda_cmd, env, args):
    """
    Utility to create the a conda command based on an env
    """
    cmd = []

    if conda is None:
        # Assume `conda` is on the PATH
        cmd.extend(['conda'])
    else:
        cmd.extend([conda])

    cmd.extend([conda_cmd])

    if env != None:
        if '/' in env:
            # env is a path e.g. /home/ubuntu/envs/base
            cmd.extend(['-p', env])
        else:
            cmd.extend(['-n', env])

    if args != None and args != []:
        cmd.extend(args)

    return cmd


def managed(name, packages=None, requirements=None, env=None, conda=None, env_path=None, user=None):
    """
    Create and install python requirements in a conda enviroment
    pip is isntalled by default in the new enviroment

    packages : None
        single packge or list of packages to install i.e. numpy, scipy=0.13.3, pandas
    requirements : None
        path to a `requirements.txt` file in the `pip freeze` format
    env : None
        environment name or path where to put the new enviroment
        if None (default) will use the default conda environment (`~/anaconda/bin`)
    conda : None
        Location for the `conda` command
        if None it is asumed the `conda` cmd is in the PATH
    env_path : None
        Absolute path to the conda virtual environment, mainly used to find the `pip` excecutable
    user
        The user under which to run the commands
    """
    ans = {}
    ans['name'] = name
    ans['changes'] = {}
    ans['comment'] = []
    ans['result'] = True

    # Create environment
    if env != None:
        cmd = create_conda_cmd(conda, 'create', env, ['pip', '--yes', '-q'])
        ret = execcmd(cmd, user)

        if ret['retcode'] == 0:
            ans['comment'].append('Virtual enviroment "%s" created' % env)
            ans['changes'][env] = 'Virtual enviroment created'
        else:
            if ret['stderr'].startswith('Error: prefix already exists:'):
                ans['comment'].append('Virtual enviroment "%s" already exists' % env)
            else:
                # Another error
                ans['comment'] = ret['stderr']
                ans['result'] = False
                return ans

    # Install packages
    if packages is not None:
        installation_ans = installed(packages, env, conda=conda, env_path=env_path, user=user)
        ans['result'] = ans['result'] and installation_ans['result']
        ans['comment'].append('From list [%s]' % installation_ans['comment'])
        ans['changes'].update(installation_ans['changes'])

    if requirements is not None:
        installation_ans = installed(requirements, env, conda=conda, env_path=env_path, user=user)
        ans['result'] = ans['result'] and installation_ans['result']
        ans['comment'].append('From file [%s]' % installation_ans['comment'])
        ans['changes'].update(installation_ans['changes'])

    ans['comment'] = '. '.join(ans['comment'])
    return ans


def installed(name, env=None, conda=None, env_path=None, user=None):
    """
    Installs a single package, list of packages (comma separated) or packages in a requirements.txt

    Checks if the package is already in the environment.
    Check ocurres here so is only needed to `conda list` and `pip freeze` once

    name
        name of the package(s) or path to the requirements.txt
    env : None
        environment name or path where to put the new enviroment
        if None (default) will use the default conda environment (`~/anaconda/bin`)
    conda : None
        Location for the `conda` command
        if None it is asumed the `conda` cmd is in the PATH
    env_path : None
        Absolute path to the conda virtual environment, mainly used to find the `pip` excecutable
    user
        The user under which to run the commands
    """
    ans = {}
    ans['name'] = name
    ans['changes'] = {}
    ans['result'] = True

    if conda is None:
        # Assume `conda` is on the PATH
        conda = 'conda'

    # Get list of installed packages
    freeze = [os.path.join(env_path, 'bin', 'pip'), 'freeze']
    ret = execcmd(freeze, user)
    freeze = ret['stdout'].lower()

    conda_list = create_conda_cmd(conda, 'list', env, None)
    ret = execcmd(conda_list, user)
    conda_list = ret['stdout'].lower()

    # Read list of requirements
    packages = []
    if os.path.exists(name) or name.startswith('salt://'):
        # Is a requirements.txt file
        if name.startswith('salt://'):
            lines = __salt__['cp.get_file_str'](name)
            lines = lines.split('\n')
        elif os.path.exists(name):
            # name is a file
            lines = open(name, mode='r').readlines()

        for line in lines:
            line = line.strip()
            if line == '' or line.startswith('#'):
                # Empty line or comment, go to next line
                continue
            else:
                line = line.split('#')[0].strip()  # Remove inline comments
                packages.append(line)
    else:
        # Is not a file, is a single package or list of packages separated by commas
        temp = name.split(',')
        for package in temp:
            packages.append(package.strip())

    # Install packages
    old = []
    failed = []
    installed = []
    for package in packages:
        # Check if installed via conda or pip
        pkgname, pkgversion = package, ''
        pkgname, pkgversion = (package.split('==')[0], package.split('==')[1]) if '==' in package else (package, pkgversion)
        pkgname, pkgversion = (package.split('>=')[0], package.split('>=')[1]) if '>=' in package else (pkgname, pkgversion)
        pkgname, pkgversion = (package.split('>')[0], package.split('>=')[1]) if '>' in package else (pkgname, pkgversion)
        conda_pkgname = pkgname + ' ' * (26 - len(pkgname)) + pkgversion

        if conda_pkgname in conda_list or package in freeze:
            old.append(package)
        else:
            ret = _install(package, env=env, conda=conda, env_path=env_path, user=user)
            if ret == 'OK':
                ans['changes'][package] = 'installed'
                installed.append(package)
            else:
                ans['changes'][package] = 'error'
                failed.append(package)

    comment = '{0} packages installed, {1} already in installed, {2} failed'
    ans['comment'] = comment.format(len(installed), len(old), len(failed))
    ans['comment'] = ans['comment'] + ':' + str(failed) if len(failed) > 0 else ans['comment']

    if len(failed) > 0:
        ans['result'] = False
    return ans


def _install(package, env=None, conda=None, env_path=None, user=None):
    """
    Helper function to install a single package from conda or defaulting to pip
    Note: Does not check if package is already installed

    env : None
        environment name or path where to put the new enviroment
        if None (default) will use the default conda environment (`~/anaconda/bin`)
    conda : None
        Location for the `conda` command
        if None it is asumed the `conda` cmd is in the PATH
    env_path : None
        Absolute path to the conda virtual environment, mainly used to find the `pip` excecutable
    user
        The user under which to run the commands

    Returns
    -------
        string: "OK", "OLD" OR "ERROR: message"
    """
    if conda is None:
        conda = 'conda'

    pip_base_cmd = [os.path.join(env_path, 'bin', 'pip'), 'install', '-q']

    # If its a git repo install using pip
    if package.startswith('git'):
        cmd = pip_base_cmd + [package]
        ret = execcmd(cmd, user)
        if ret['retcode'] == 0:
            return 'OK'
        else:
            return 'ERROR: ' + ret['stderr']

    # Install package from conda or pip
    cmd = create_conda_cmd(conda, 'install', env, [package, '--yes', '-q'])
    ret = execcmd(cmd, user)

    if ret['retcode'] == 0:
        return 'OK'
    else:
        if 'Error: No packages found matching:' in ret['stderr']:
            # Package not available through conda try pypi
            cmd = pip_base_cmd + [package]
            ret = execcmd(cmd, user)

            if ret['retcode'] == 0:
                return 'OK'
            else:
                return 'ERROR: Package %s not found on conda or pypi' % package
        else:
            # Another conda error
            return 'ERROR: ' + ret['stderr']
