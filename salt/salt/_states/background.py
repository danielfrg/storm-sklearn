import os

def running(name, pid='', stdout=None, stderr=None, cwd=None, writepid=True, force=False, user=None):
    '''

    writepid: False,
        usefull when the process writes its own pid but still want to kill it everytime

    '''
    ans = {}
    ans['name'] = name
    ans['changes'] = {}
    ans['result'] = True
    ans['comment'] = ''

    if os.path.exists(pid) and os.path.isfile(pid):
        f = open(pid, 'r')
        oldpid = f.read().strip()
        f.close()

        if force:
            # Kill process on that pid
            cmd = 'kill {pid} && rm {pidfile}'.format(pid=oldpid, pidfile=pid)
            __salt__['cmd.run_all'](cmd, runas=user)
            ans['changes']['old'] = 'Killed process %s' % oldpid
        else:
            ans['comment'] = 'Process is already running with pid: %s' % oldpid
            return ans

    if stdout and stderr:
        cmd = '{cmd} >> {stdout} 2>> {stderr} &'
        cmd = cmd.format(cmd=name, stdout=stdout, stderr=stderr)
    else:
        cmd = '{cmd} &'.format(cmd=name)

    dic = __salt__['cmd.run_all'](cmd, cwd=cwd, runas=user)
    newpid = dic['pid'] + 1

    if pid and writepid:
        # write pid file
        cmd = "echo {pid} > {pidfile}".format(pid=newpid, pidfile=pid)
        __salt__['cmd.run_all'](cmd, runas=user)

    ans['comment'] = 'New background process running with pid {0}'.format(newpid)
    ans['changes']['new'] = 'New background process running with pid {0}'.format(newpid)

    return ans
