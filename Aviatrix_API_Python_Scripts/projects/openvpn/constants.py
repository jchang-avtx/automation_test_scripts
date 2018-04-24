# Copyright (c) 2014-2018, Aviatrix Systems, Inc.

#Global variables
SSH_OPTS_FLG = '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                -o ConnectionAttempts=120 -o ConnectTimeout=120 '
CONFIG_PATH = './config/'
LOG_PATH = './log/'
CFG_EXT = '.cfg'
SSHKEY_EXT = '-sshkey.pem'
OVPN_EXT = '.ovpn'
USER_CFG_PATH = './user_config.json'
RESULT_PATH = './log/result.json'
