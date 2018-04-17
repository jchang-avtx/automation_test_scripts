# Copyright (c) 2018, Aviatrix Systems, Inc.

#########################################################################################################
#Site2Cloud end to end test
#1. Create client AWS VPC and client instance
#2. Create server AWS VPC and server instance
#3. Setup Aviatrix access account
#4. Launch Aviatrix gateway in both AWS client and server instance
#5. Build site2cloud from Aviatrix gateway from server to client and client to server
#6. Ping from end to end
#########################################################################################################

import os
import logging
import json
import sys
import time
import traceback
from constants import SSH_OPTS_FLG
from constants import CONFIG_PATH
from constants import LOG_PATH
from constants import CFG_EXT
from constants import SSHKEY_EXT
from constants import OVPN_EXT
from constants import RESULT_PATH

sys.path.append('../..')

from lib.aws.ec2 import aws_create_vpc
from lib.aws.ec2 import aws_stop_instance
from lib.aviatrix.account import create_cloud_account
from lib.aviatrix.gateway import create_gateway
from lib.aviatrix.gateway import get_gateway_info
from lib.aviatrix.site2cloud import create_site2cloud
from lib.util.util import set_logger
from lib.util.ssh_session import SSHSession
from lib.util.util import read_config_file
from lib.util.util import write_config_file
from lib.aviatrix.initial_setup import login_GET_method

from lib.aws.ec2 import aws_delete_vpc
from lib.aviatrix.account import delete_cloud_account
from lib.aviatrix.gateway import delete_gateway_api
from lib.aviatrix.site2cloud import delete_site2cloud

logger = logging.getLogger(__name__)

class Site2Cloud(object):
    def __init__(self, argv):
        config_file = './' + argv[1]
        logger.info('config_file: {}'.format(config_file))
        cfg = read_config_file(file_path=config_file)
        self.account_name = cfg['account_name']
        self.account_password = cfg['account_password']
        self.account_email = cfg['account_email']
        self.cloud_type = cfg['cloud_type']
        self.aws_account_number = cfg['aws_account_number']
        self.aws_access_key_id = cfg['aws_access_key_id']
        self.aws_secret_access_key = cfg['aws_secret_access_key']
        self.ucc_public_ip = cfg['ucc_public_ip']
        self.controller_username = cfg['controller_username']
        self.controller_password = cfg['controller_password']
        self.region_client = cfg['region_client']
        self.region_server = cfg['region_server']
        self.vpc_client_cidr = cfg['vpc_client_cidr']
        self.vpc_server_cidr = cfg['vpc_server_cidr']
        self.vpc_client_tag = cfg['vpc_client_tag']
        self.vpc_server_tag = cfg['vpc_server_tag']
        self.vpc_client_subnet_cidr = cfg['vpc_client_subnet_cidr']
        self.vpc_server_subnet_cidr = cfg['vpc_server_subnet_cidr']
        self.gateway_size = cfg['gateway_size']
        self.gateway_name = cfg['gateway_name']
        self.gateway_site_name = cfg['gateway_site_name'] 
        self.gateway_site_size = cfg['gateway_site_size']
        self.connection_name_cloud = cfg['connection_name_cloud']
        self.connection_name_site = cfg['connection_name_site']
        self.connection_type_cloud = cfg['connection_type_cloud']
        self.connection_type_site = cfg['connection_type_site']
        self.s2c_psk = cfg['s2c_psk']
        self.ha_enable = cfg['ha_enable']
        self.base_url = "https://" + self.ucc_public_ip + "/v1/api"
    def validate_input(self):
        reason = ''
        if self.cloud_type != 1:
            reason = 'cloud_type not AWS'
            return False, reason
        if not self.account_name:
            reason = 'account_name missing'
            return False, reason
        if not self.account_password:
            reason = 'account_password missing'
            return False, reason
        if not self.account_email:
            reason = 'account_email missing'
            return False, reason
        if not self.aws_account_number:
            reason = 'aws_account_number missing'
            return False, reason
        if not self.aws_access_key_id:
            reason = 'aws_access_key_id missing'
            return False, reason
        if not self.aws_secret_access_key:
            reason = 'aws_secret_access_key missing'
            return False, reason
        if not self.ucc_public_ip:
            reason = 'ucc_public_ip missing'
            return False, reason
        if not self.controller_username:
            reason = 'controller_username missing'
            return False, reason
        if not self.controller_password:
            reason = 'controller_password missing'
            return False, reason
        if not self.region_client:
            reason = 'region_client missing'
            return False, reason
        if not self.region_server:
            reason = 'region_server missing'
            return False, reason
        if not self.vpc_client_tag:
            reason = 'vpc_client_tag missing'
            return False, reason
        if not self.vpc_server_tag:
            reason = 'vpc_server_tag missing'
            return False, reason
        if not self.vpc_client_cidr:
            reason = 'vpc_client_cidr missing'
            return False, reason
        if not self.vpc_client_subnet_cidr:
            reason = 'vpc_client_subnet_cidr missing'
            return False, reason
        if not self.vpc_server_cidr:
            reason = 'vpc_server_cidr missing'
            return False, reason
        if not self.vpc_server_subnet_cidr:
            reason = 'vpc_server_subnet_cidr missing'
            return False, reason
        if not self.gateway_size:
            reason = 'gateway_size missing'
            return False, reason
        if not self.gateway_name:
            reason = 'gateway_name missing'
            return False, reason
        if not self.gateway_site_size:
            reason = 'gateway_site_size missing'
            return False, reason
        if not self.gateway_site_name:
            reason = 'gateway_site_name missing'
            return False, reason
        if not self.connection_name_cloud:
            reason = 'connection_name_cloud missing'
            return False, reason
        if not self.connection_name_site:
            reason = 'connection_name_site missing'
            return False, reason
        if not self.connection_type_cloud:
            reason = 'connection_type_cloud missing'
            return False, reason
        if not self.connection_type_site:
            reason = 'connection_type_site missing'
            return False, reason
        return True, reason

    def handle_api_error(self, response, raise_except=False):
        reason = ''
        resp_json = response.json()
        logger.info('response: {}'.format(resp_json))
        if not resp_json['return']:
            reason = resp_json["reason"]
            if raise_except:
                raise Exception(reason)
        return reason

    def build_avx_site2cloud(self):

        cfg_file_client = CONFIG_PATH + self.vpc_client_tag + CFG_EXT
        private_key = CONFIG_PATH + self.vpc_client_tag + SSHKEY_EXT
        logger.info('cfg_file_client: {}'.format(cfg_file_client))
        logger.info('private_key: {}'.format(private_key))

        # create client vpc with client ubuntu instance
        logger.info('Begin creating Client VPC and instance ...')

        aws_create_vpc(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_client,
                       vpc_cidr=self.vpc_client_cidr,
                       vpc_name_tag=self.vpc_client_tag,
                       subnet_cidr=self.vpc_client_subnet_cidr,
                       create_instance=True,
                       cfg_file=CONFIG_PATH)
        logger.info('End creating Client VPC and instance .')

        aws_cfg = read_config_file(file_path=cfg_file_client)


        # create server vpc with server ubuntu instance
        logger.info('Begin creating Server VPC and instance ...')
        aws_create_vpc(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_server,
                       vpc_cidr=self.vpc_server_cidr,
                       vpc_name_tag=self.vpc_server_tag,
                       subnet_cidr=self.vpc_server_subnet_cidr,
                       create_instance=True,
                       cfg_file=CONFIG_PATH)
        logger.info('End creating Server VPC and instance .')

        # Login controller
        logger.info('Begin login controller...')
        response = login_GET_method(
                       url=self.base_url, 
                       username=self.controller_username, 
                       password=self.controller_password)
        resp_json = response.json()
        if resp_json["return"]:
            CID = resp_json["CID"]
        logger.info(msg="CID: " + CID)
        logger.info('End login controller.')
        self.handle_api_error(response, raise_except=True)

        # create Aviatrix cloud access account
        logger.info('Begin creating Aviatrix cloud access account...')
        logger.info('account_name: {}'.format(self.account_name))
        logger.info('account_password: {}'.format(self.account_password))
        logger.info('cloud_type: {}'.format(self.cloud_type))

        response = create_cloud_account(
                             url=self.base_url,
                             CID=CID,
                             account_name=self.account_name,
                             account_password=self.account_password,
                             account_email=self.account_email,
                             cloud_type=self.cloud_type,
                             aws_account_number=self.aws_account_number,
                             iam_role_based=False,
                             aws_access_key_id=self.aws_access_key_id,
                             aws_secret_access_key=self.aws_secret_access_key)
        logger.info('End creating aviatrix cloud access account...')
        self.handle_api_error(response, raise_except=True)
        

        # launch Aviatrix gateway
        logger.info('Begin launching Aviatrix gateway...')

        cfg_file_server = CONFIG_PATH + self.vpc_server_tag + CFG_EXT
        aws_cfg_server = read_config_file(file_path=cfg_file_server)
        vpc_server_id  = aws_cfg_server['vpc_id']
        subnet_name = self.vpc_server_subnet_cidr + '~~' + self.region_server + \
                      '~~' + self.vpc_server_tag + '-public'

        response = create_gateway(
                       url=self.base_url,
                       CID=CID,
                       avx_cloud_account_name=self.account_name,
                       cloud_type=self.cloud_type,
                       vpc_region=self.region_server,
                       vpc_id=vpc_server_id,
                       subnet_name=subnet_name,
                       gateway_size=self.gateway_size,
                       gateway_name=self.gateway_name,
                       allocate_new_eip="on",
                       vpn_access="no")
        logger.info('End launching Aviatrix gateway.')
        self.handle_api_error(response, raise_except=True)

        # launch site Aviatrix gateway
        logger.info('Begin launching site Aviatrix gateway...')

        vpc_client_id  = aws_cfg['vpc_id']
        subnet_name = self.vpc_client_subnet_cidr + '~~' + \
                      self.region_client + '~~' + self.vpc_client_tag + '-public'

        response = create_gateway(
                       url=self.base_url,
                       CID=CID,
                       avx_cloud_account_name=self.account_name,
                       cloud_type=self.cloud_type,
                       vpc_region=self.region_client,
                       vpc_id=vpc_client_id,
                       subnet_name=subnet_name,
                       gateway_size=self.gateway_site_size,
                       gateway_name=self.gateway_site_name,
                       allocate_new_eip="on",
                       vpn_access="no")
        logger.info('End launching site Aviatrix gateway.')
        self.handle_api_error(response, raise_except=True)

        #Get cloud gateway public ip
        response_cloud = get_gateway_info(
                                    url=self.base_url,
                                    CID=CID,
                                    gateway_name=self.gateway_name)
        self.handle_api_error(response, raise_except=True)
        resp_cloud_gw = response_cloud.json()
        resp_cloud_gw = resp_cloud_gw['results']
        cloud_gw_public_ip = resp_cloud_gw['public_ip']
        cloud_gw_private_ip = resp_cloud_gw['private_ip']
        cloud_gw_vpc_id = resp_cloud_gw['vpc_id'] + '~~' + resp_cloud_gw['vpc_name_tag']
        cloud_gw_subnet_cidr = resp_cloud_gw['gw_subnet_cidr']
        cloud_gw_inst_id = resp_cloud_gw['cloudx_inst_id']
        logger.info('cloud_gw_public_ip: {}'.format(cloud_gw_public_ip))
        logger.info('cloud_gw_private_ip: {}'.format(cloud_gw_private_ip))
        logger.info('cloud_gw_vpc_id: {}'.format(cloud_gw_vpc_id))
        logger.info('cloud_gw_subnet_cidr: {}'.format(cloud_gw_subnet_cidr))
        logger.info('cloud_gw_inst_id: {}'.format(cloud_gw_inst_id))

        #Get site gateway public ip
        response_site = get_gateway_info(
                                    url=self.base_url,
                                    CID=CID,
                                    gateway_name=self.gateway_site_name)
        self.handle_api_error(response, raise_except=True)
        resp_site_gw = response_site.json()
        resp_site_gw = resp_site_gw['results']
        site_gw_public_ip = resp_site_gw['public_ip']
        site_gw_private_ip = resp_site_gw['private_ip']
        site_gw_vpc_id = resp_site_gw['vpc_id']
        site_gw_subnet_cidr = resp_site_gw['gw_subnet_cidr']
        logger.info('site_gw_public_ip: {}'.format(site_gw_public_ip))
        logger.info('site_gw_prvate_ip: {}'.format(site_gw_private_ip))
        logger.info('site_gw_vpc_id: {}'.format(site_gw_vpc_id))
        logger.info('site_gw_subnet_cidr: {}'.format(site_gw_subnet_cidr))

        if self.ha_enable == 'true':
        
            # launch backup Aviatrix gateway
            logger.info('Begin launching backup Aviatrix gateway...')
            subnet_name = self.vpc_server_subnet_cidr + '~~' + self.region_server + \
                      '~~' + self.vpc_server_tag + '-public'
            response = create_gateway(
                           url=self.base_url,
                           CID=CID,
                           avx_cloud_account_name=self.account_name,
                           cloud_type=self.cloud_type,
                           vpc_region=self.region_server,
                           vpc_id=vpc_server_id,
                           subnet_name=subnet_name,
                           gateway_size=self.gateway_size,
                           gateway_name=self.gateway_name + '-ha',
                           allocate_new_eip="on",
                           vpn_access="no")
            logger.info('End launching backup Aviatrix gateway.')
            self.handle_api_error(response, raise_except=True)

            # launch backup site Aviatrix gateway
            logger.info('Begin launching backup site Aviatrix gateway...')

            subnet_name = self.vpc_client_subnet_cidr + '~~' + \
                          self.region_client + '~~' + self.vpc_client_tag + '-public'

            response = create_gateway(
                           url=self.base_url,
                           CID=CID,
                           avx_cloud_account_name=self.account_name,
                           cloud_type=self.cloud_type,
                           vpc_region=self.region_client,
                           vpc_id=vpc_client_id,
                           subnet_name=subnet_name,
                           gateway_size=self.gateway_site_size,
                           gateway_name=self.gateway_site_name + '-ha',
                           allocate_new_eip="on",
                           vpn_access="no")
            logger.info('End launching backup site Aviatrix gateway.')
            self.handle_api_error(response, raise_except=True)

            #Get cloud backup gateway public ip
            logger.info('Begin getting cloud backup gateway info...')
            response_cloud = get_gateway_info(
                                        url=self.base_url,
                                        CID=CID,
                                        gateway_name=self.gateway_name + '-ha')
            logger.info('End getting cloud backup gateway info.')
            self.handle_api_error(response, raise_except=True)
            bk_resp_cloud_gw = response_cloud.json()
            bk_resp_cloud_gw = bk_resp_cloud_gw['results']
            bk_cloud_gw_public_ip = bk_resp_cloud_gw['public_ip']
            bk_cloud_gw_private_ip = bk_resp_cloud_gw['private_ip']
            bk_cloud_gw_vpc_id = bk_resp_cloud_gw['vpc_id'] + '~~' + bk_resp_cloud_gw['vpc_name_tag']
            bk_cloud_gw_subnet_cidr = bk_resp_cloud_gw['gw_subnet_cidr']
            logger.info('bk_cloud_gw_public_ip: {}'.format(bk_cloud_gw_public_ip))
            logger.info('bk_cloud_gw_private_ip: {}'.format(bk_cloud_gw_private_ip))
            logger.info('bk_cloud_gw_vpc_id: {}'.format(bk_cloud_gw_vpc_id))
            logger.info('bk_cloud_gw_subnet_cidr: {}'.format(bk_cloud_gw_subnet_cidr))

            #Get site backup gateway public ip
            logger.info('Begin getting site backup gateway info...')
            response_site = get_gateway_info(
                                        url=self.base_url,
                                        CID=CID,
                                        gateway_name=self.gateway_site_name + '-ha')
            logger.info('End getting site backup gateway info.')
            self.handle_api_error(response, raise_except=True)
            bk_resp_site_gw = response_site.json()
            bk_resp_site_gw = bk_resp_site_gw['results']
            bk_site_gw_public_ip = bk_resp_site_gw['public_ip']
            bk_site_gw_private_ip = bk_resp_site_gw['private_ip']
            bk_site_gw_vpc_id = bk_resp_site_gw['vpc_id']
            bk_site_gw_subnet_cidr = bk_resp_site_gw['gw_subnet_cidr']
            logger.info('bk_site_gw_public_ip: {}'.format(bk_site_gw_public_ip))
            logger.info('bk_site_gw_prvate_ip: {}'.format(bk_site_gw_private_ip))
            logger.info('bk_site_gw_vpc_id: {}'.format(bk_site_gw_vpc_id))
            logger.info('bk_site_gw_subnet_cidr: {}'.format(bk_site_gw_subnet_cidr))

        #build site2cloud from Aviatrix GW to site
        logger.info('Begin build cloud2site...')
        ha_enabled = self.ha_enable
        if ha_enabled == 'true':
           backup_gateway_name = self.gateway_name + '-ha'
           remote_backup_gateway_ip = bk_site_gw_public_ip
        else:
           backup_gateway_name = None
           remote_backup_gateway_ip = None
        logger.info('backup_gateway_name: {}'.format(backup_gateway_name))
        logger.info('remote_backup_gateway_ip: {}'.format(remote_backup_gateway_ip))
        resp_cloud_s2c= create_site2cloud(
                       url=self.base_url,
                       CID=CID,
                       vpc_id=cloud_gw_vpc_id,
                       connection_name=self.connection_name_cloud,
                       connection_type=None,
                       remote_gateway_type=self.connection_type_site,
                       tunnel_type=None,
                       primary_gateway_name=self.gateway_name,
                       remote_primary_gateway_ip=site_gw_public_ip,
                       pre_shared_key=self.s2c_psk,
                       local_subnet_cidr=None,
                       remote_subnet_cidr=site_gw_subnet_cidr,
                       ha_enabled=ha_enabled,
                       backup_gateway_name=backup_gateway_name,
                       remote_backup_gateway_ip=remote_backup_gateway_ip,
                       pre_shared_key_for_backup_connection=self.s2c_psk)

        logger.info('End build cloud2site.')
        self.handle_api_error(response, raise_except=True)

        #build site2cloud from site to Aviatrix GW
        logger.info('Begin build site2cloud...')
        if ha_enabled == 'true':
           backup_gateway_name = self.gateway_site_name + '-ha'
           remote_backup_gateway_ip = bk_cloud_gw_public_ip
        else:
           backup_gateway_name = None
           remote_backup_gateway_ip = None

        logger.info('backup_gateway_name: {}'.format(backup_gateway_name))
        logger.info('remote_backup_gateway_ip: {}'.format(remote_backup_gateway_ip))
        resp_site_s2c = create_site2cloud(
                       url=self.base_url,
                       CID=CID,
                       vpc_id=site_gw_vpc_id,
                       connection_name=self.connection_name_site,
                       connection_type=None,
                       remote_gateway_type=self.connection_type_cloud,
                       tunnel_type=None,
                       primary_gateway_name=self.gateway_site_name,
                       pre_shared_key=self.s2c_psk,
                       remote_primary_gateway_ip=cloud_gw_public_ip,
                       local_subnet_cidr=None,
                       remote_subnet_cidr=cloud_gw_subnet_cidr,
                       ha_enabled=ha_enabled,
                       backup_gateway_name=backup_gateway_name,
                       remote_backup_gateway_ip=remote_backup_gateway_ip,
                       pre_shared_key_for_backup_connection=self.s2c_psk)

        logger.info('End build site2cloud.')
        self.handle_api_error(response, raise_except=True)

        #ping from user instance
        ssh = SSHSession(aws_cfg['inst_public_ip'], 'ubuntu', ssh_key=private_key)
        time.sleep(180)
        cmd = 'ping -c 2 -w 2 ' + aws_cfg_server['inst_private_ip']
        result = ssh.exec_cmd(cmd, ignore_exit_status=True)
        logger.info('ssh result {}'.format(result))
        if '100% packet loss' in str(result['stdout']):
            logger.error('Ping failed')
        else:
            logger.info('Ping success')

        # Test out ha case
        if ha_enabled == "true":
            #stop cloud gateway
            aws_stop_instance(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_server,
                       instance_id=cloud_gw_inst_id)
            time.sleep(120)
            logger.info('Ping after switch over')
            cmd = 'ping -c 2 -w 2 ' + aws_cfg_server['inst_private_ip']
            result = ssh.exec_cmd(cmd, ignore_exit_status=True)
            logger.info('ssh result {}'.format(result))
            if '100% packet loss' in str(result['stdout']):
                logger.error('Ping failed')
            else:
                logger.info('Ping success')
            
        ssh.close()

    def delete_server_instance_vpc(self):
        logger.info('Begin deleting server instance and vpc ...')
        cfg_file_server = CONFIG_PATH + self.vpc_server_tag + CFG_EXT
        server_ssh = CONFIG_PATH + self.vpc_server_tag + SSHKEY_EXT
        aws_cfg = read_config_file(file_path=cfg_file_server)
        logger.info('server vpc_id: {}'.format(aws_cfg['vpc_id']))
        aws_delete_vpc(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_server,
                       vpc_name_tag=self.vpc_server_tag,
                       vpc_id=aws_cfg["vpc_id"])
        cmd = 'sudo rm ' + cfg_file_server
        logger.info('cmd: {}'.format(cmd))
        os.system(cmd)
        cmd = 'sudo rm ' + server_ssh
        logger.info('cmd: {}'.format(cmd))
        os.system(cmd)
        logger.info('End deleting server instance.')

    def delete_client_instance_vpc(self):
        logger.info('Begin deleting client instance and vpc...')
        cfg_file_client = CONFIG_PATH + self.vpc_client_tag + CFG_EXT
        client_ssh = CONFIG_PATH + self.vpc_client_tag + SSHKEY_EXT
        aws_cfg = read_config_file(file_path=cfg_file_client)
        logger.info('client vpc_id: {}'.format(aws_cfg['vpc_id']))
        aws_delete_vpc(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_client,
                       vpc_name_tag=self.vpc_client_tag,
                       vpc_id=aws_cfg["vpc_id"])
        cmd = 'sudo rm ' + cfg_file_client
        logger.info('cmd: {}'.format(cmd))
        os.system(cmd)
        cmd = 'sudo rm ' + client_ssh
        logger.info('cmd: {}'.format(cmd))
        os.system(cmd)
        logger.info('End deleting client instance.')

    def remove_avx_site2cloud(self):
        reason = ''
        # Login controller
        logger.info('Begin login controller...')
        response = login_GET_method(
                       url=self.base_url, 
                       username=self.controller_username, 
                       password=self.controller_password)
        resp_json = response.json()
        if resp_json["return"]:
            CID = resp_json["CID"]
            logger.info(msg="CID: " + CID)
        else:
            reason = reason + self.handle_api_error(response)
        logger.info('End login controller.')

        cfg_file_client = CONFIG_PATH + self.vpc_client_tag + CFG_EXT
        aws_cfg = read_config_file(file_path=cfg_file_client)
        vpc_site_id  = aws_cfg['vpc_id']
        logger.info('vpc_site_id: {}'.format(vpc_site_id))

        cfg_file_server = CONFIG_PATH + self.vpc_server_tag + CFG_EXT
        aws_cfg_server = read_config_file(file_path=cfg_file_server)
        vpc_cloud_id  = aws_cfg_server['vpc_id']
        logger.info('vpc_cloud_id: {}'.format(vpc_cloud_id))

        # delete s2c site-cloud
        logger.info('Begin deleting site-cloud connection...')
        resp = delete_site2cloud(
            url=self.base_url,
            CID=CID,
            vpc_id=vpc_site_id,
            connection_name=self.connection_name_site)
        logger.info('End deleting site-cloud connection')
        reason = reason + self.handle_api_error(response)

        # delete s2c cloud-site
        logger.info('Begin deleting cloud-site connection...')
        resp = delete_site2cloud(
            url=self.base_url,
            CID=CID,
            vpc_id=vpc_cloud_id,
            connection_name=self.connection_name_cloud)

        logger.info('End deleting cloud-site connection.')
        reason = reason + self.handle_api_error(response)

        # delete Aviatrix cloud gateway
        logger.info('Begin deleting Aviatrix cloud gateway...')
        response = delete_gateway_api(
                       url=self.base_url,
                       CID=CID,
                       cloud_type=self.cloud_type,
                       gateway_name=self.gateway_name,
                       max_retry=10)
        
        logger.info('End deleting Aviatrix cloud gateway.')
        reason = reason + self.handle_api_error(response)

        # delete Aviatrix site gateway
        logger.info('Begin deleting Aviatrix site gateway...')
        response = delete_gateway_api(
                       url=self.base_url,
                       CID=CID,
                       cloud_type=self.cloud_type,
                       gateway_name=self.gateway_site_name,
                       max_retry=10)
        logger.info('End deleting Aviatrix site gateway.')
        reason = reason + self.handle_api_error(response)

        if self.ha_enable == 'true':
            # delete backup Aviatrix cloud gateway
            logger.info('Begin backup deleting Aviatrix cloud gateway...')
            response = delete_gateway_api(
                           url=self.base_url,
                           CID=CID,
                           cloud_type=self.cloud_type,
                           gateway_name=self.gateway_name + '-ha',
                           max_retry=10)

            logger.info('End deleting Aviatrix cloud gateway.')
            reason = reason + self.handle_api_error(response)

            # delete backup Aviatrix site gateway
            logger.info('Begin deleting backup Aviatrix site gateway...')
            response = delete_gateway_api(
                           url=self.base_url,
                           CID=CID,
                           cloud_type=self.cloud_type,
                           gateway_name=self.gateway_site_name + '-ha',
                           max_retry=10)
            logger.info('End deleting backup Aviatrix site gateway.')
            reason = reason + self.handle_api_error(response)

        
        # delete account
        logger.info('Begin deleting Aviatrix access account...')
        logger.info('account_name: {}'.format(self.account_name))
        response = delete_cloud_account(
                       url=self.base_url,
                       CID=CID,
                       account_name=self.account_name)
        logger.info('End deleting Aviatrix access account.')
        reason = reason + self.handle_api_error(response)

        self.delete_client_instance_vpc()
        self.delete_server_instance_vpc()
        return reason

def validate_args(argv):
    reason = ''
    if len(argv) < 3:
        reason = 'missing config file and action input'
        logger.error(reason)
        return reason
    config_file = './' + str(argv[1])
    logger.info('config_file: {}'.format(config_file))
    if not os.path.exists(config_file):
        reason = argv[1] + ' does not exist.'
        logger.error(reason)
    logger.info('argv2: {}'.format(argv[2]))
    if argv[2] != 'create' and argv[2]!= 'delete' and argv[2]!= 'create-delete':
        reason =  argv[2] + ' not part of keyword create, delete, create-delete'
        logger.error(reason)

    return reason

def main(argv):
    logger = set_logger(path_to_log_file= LOG_PATH + 'test.log')
    result = {}

    reason = validate_args(argv)
    if reason:
        return

    site2cloud = Site2Cloud(argv)
    if 'create' in argv[2]:
        ret, reason = site2cloud.validate_input()

        if not ret:
            logger.error(reason)
            return
    if 'create' in argv[2]:
        try:
            site2cloud.build_avx_site2cloud()
            result['create_return'] = True
            result['create_results'] = 'AWS Create Site2Cloud successful.'
        except Exception as e:
            reason = str(e)
            logger.error(reason)
            logger.error(str(traceback.format_exc()))
            result['return'] = False
            result['results'] = reason
    if 'delete' in argv[2]:
        if argv[2] == 'create-delete':
            time.sleep(120)
        try:
            ret = site2cloud.remove_avx_site2cloud()
            if not ret:
                result['delete_return'] = True
                result['delete_results'] = 'AWS Delete Site2Cloud successful.'
            else:
                result['delete_return'] = False
                result['delete_results'] = 'AWS Delete Site2Cloud Failed.' + ret
        except Exception as e:
            reason = str(e)
            logger.error(reason)
            logger.error(str(traceback.format_exc()))
            result['delete_return'] = False
            result['delete_results'] = 'AWS Delete Site2Cloud Failed. ' + reason
    write_config_file(file_path=RESULT_PATH, cfg=result)


if __name__ == "__main__":
    main(sys.argv)

