# Copyright (c) 2014, 2015 Carmelo Systems, Inc.
#! Remote ssh utils 

import logging
import traceback
import paramiko


class SSHSessionError(Exception):
      pass


class SSHSession:
    def __init__(self, host, ssh_username, ssh_key=None,
                 ssh_password=None, timeout=6):
        self.logger = logging.getLogger(__name__)
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            if ssh_password is not None:
                self.ssh.connect(host, username=ssh_username, 
                                 password=ssh_password,
                                 timeout=timeout)
            else:
                self.ssh.connect(host, username=ssh_username, 
                                 key_filename=ssh_key,
                                 timeout=timeout)

        except Exception as e:
            err = 'SSH session failure: {}'.format(str(e))
            self.logger.error(str(traceback.format_exc()))
            self.logger.error(err)
            raise SSHSessionError(err)

    def exec_cmd(self, cmd, ignore_exit_status = False):
        self.logger.info('Executing command %s', cmd)
        stdin, stdout, stderr = self.ssh.exec_command(cmd)
        exit_status = stdout.channel.recv_exit_status()
        cmd_result = {}
        cmd_result['stdout'] = stdout.readlines()
        cmd_result['stderr'] = stderr.readlines()
        # self.logger.info('Command %s execution output: %s', cmd, cmd_result['stdout'])
        if ignore_exit_status:
            return cmd_result
        if not exit_status:
            self.logger.info('Command %s successfully executed, result %s', 
                              cmd, cmd_result)
            return cmd_result
        else:
            err = 'Command {} failed to execute'.format(cmd)
            self.logger.error(err)
            raise SSHSessionError(err)
    
    def close(self):
        self.ssh.close()
