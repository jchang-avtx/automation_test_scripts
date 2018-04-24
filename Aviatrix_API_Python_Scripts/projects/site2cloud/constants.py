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
RESULT_PATH = './log/result.'
PRIVATE_KEY_PATH = './config/vnet-key'
PARAM_PATH = '../../lib/arm/parameters.json'
TEMPLATE_PATH = '../../lib/arm/template.json'
AWS_CLOUD_TYPE_BIT = 0x01
AZURE_ARM_CLOUD_TYPE_BIT = 0x08
AWS_GOV_CLOUD_TYPE_BIT = 0x100
AZURE_ARM_CHINA_CLOUD_TYPE_BIT = 0x800
AZURE_ARM_RELATED_TYPES = [AZURE_ARM_CLOUD_TYPE_BIT, AZURE_ARM_CHINA_CLOUD_TYPE_BIT]

