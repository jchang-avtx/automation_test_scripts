# Copyright (c) 2018, Aviatrix Systems, Inc.

#########################################################################################################
#   OpenVPN end to end test
#1. Create client AWS VPC and client instance
#2. Create server AWS VPC and server instance
#3. Setup Aviatrix access account
#4. Launch Aviatrix VPN gateway
#5. Add VPN user
#6. Download VPN config file
#7. Install openvpn client on client instance, copy VPN config file to client instance, load openvpn config file and perform ping test end to end
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
from lib.aviatrix.account import create_cloud_account
from lib.aviatrix.gateway import create_gateway
from lib.aviatrix.gateway import get_gateway_info
from lib.aviatrix.openvpn import create_vpn_user
from lib.aviatrix.openvpn import get_vpn_client_cert
from lib.util.util import set_logger
from lib.util.ssh_session import SSHSession
from lib.util.util import read_config_file
from lib.util.util import write_config_file
from lib.aviatrix.initial_setup import login_GET_method
from lib.aws.ec2 import aws_delete_vpc
from lib.aviatrix.account import delete_cloud_account
from lib.aviatrix.gateway import delete_gateway_api
from lib.aviatrix.openvpn import delete_vpn_user


logger = logging.getLogger(__name__)

class VPN(object):
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
        self.vpn_cidr = cfg['vpn_cidr']
        self.vpn_username = cfg['vpn_username']
        self.vpn_user_email = cfg['vpn_user_email']
        self.elb_enable = cfg['elb_enable']
        self.elb_name = cfg['elb_name']
        self.duo_enable = cfg['duo_enable']
        self.duo_integration_key = cfg['duo_integration_key']
        self.duo_secret_key = cfg['duo_secret_key']
        self.duo_api_hostname = cfg['duo_api_hostname']
        self.base_url = "https://" + self.ucc_public_ip + "/v1/api"
        

    def validate_input(self, argv):
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
        if not self.vpn_cidr:
            reason = 'vpn_cidr missing'
            return False, reason
        if not self.gateway_size:
            reason = 'gateway_size missing'
            return False, reason
        if not self.gateway_name:
            reason = 'gateway_name missing'
            return False, reason
        if not self.vpn_username:
            reason = 'vpn_username missing'
            return False, reason
        if not self.vpn_user_email:
            reason = 'vpn_user_email missing'
            return False, reason
        if self.duo_enable:
            if not self.duo_integration_key:
                reason = 'duo_integration_key missing'
                return False, reason
            if not self.duo_secret_key:
                reason = 'duo_secret_key missing'
                return False, reason
            if not self.duo_api_hostname:
                reason = 'duo_api_hostname missing'
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

    def build_avx_openvpn(self):
        cfg_file_client = CONFIG_PATH + self.vpc_client_tag + CFG_EXT
        cfg_file_server = CONFIG_PATH + self.vpc_server_tag + CFG_EXT
        private_key = CONFIG_PATH + self.vpc_client_tag + SSHKEY_EXT
        logger.info('cfg_file_client: {}'.format(cfg_file_client))
        logger.info('cfg_file_server: {}'.format(cfg_file_server))
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
    
        aws_cfg = read_config_file(file_path=cfg_file_client)
        #install openvpn
        logger.info('Begin installing openvpn on client...')
        cmd = 'sudo apt-get -y install openvpn'
        ssh = SSHSession(aws_cfg['inst_public_ip'], 'ubuntu', ssh_key=private_key)
        result = ssh.exec_cmd(cmd, ignore_exit_status=True)
        logger.info('End installing openvpn. {}'.format(result))

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
        

        # launch Aviatrix gateway with VPN enabled
        logger.info('Begin launching Aviatrix gateway with VPN enabled...')
    
        aws_cfg_server = read_config_file(file_path=cfg_file_server)
        vpc_server_id  = aws_cfg_server['vpc_id']
        subnet_name = self.vpc_server_subnet_cidr + '~~' + \
                      self.region_server + '~~' + self.vpc_server_tag + '-public'

        if self.duo_enable:
            otp_mode = 2
            duo_integration_key = self.duo_integration_key
            duo_secret_key = self.duo_secret_key
            duo_api_hostname = self.duo_api_hostname
            duo_push_mode = 'auto'
        else:
            otp_mode = None
            duo_integration_key = None
            duo_secret_key = None
            duo_api_hostname = None
            duo_push_mode = None

        logger.info('self.elb_name: {}'.format(self.elb_name))
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
                       vpn_access="yes", 
                       vpn_cidr=self.vpn_cidr, 
                       split_tunnel="yes", 
                       max_connection=100, 
                       enable_elb=self.elb_enable,
                       elb_name=self.elb_name,
                       otp_mode=otp_mode,
                       duo_integration_key=duo_integration_key, 
                       duo_secret_key=duo_secret_key, 
                       duo_api_hostname=duo_api_hostname, 
                       duo_push_mode=duo_push_mode)
        logger.info('End launching Aviatrix gateway with VPN enabled.')
        self.handle_api_error(response, raise_except=True)

        logger.info('Begin getting Aviatrix gateway info...')
        response = get_gateway_info(
                       url=self.base_url,
                       CID=CID,
                       gateway_name=self.gateway_name)
        logger.info('End getting Aviatrix gateway info.')
        self.handle_api_error(response, raise_except=True)
        resp = response.json()
        cfg_gw = resp['results']
        logger.info('cfg_gw: {}'.format(cfg_gw))

        #Add VPN user
        elb = cfg_gw.get('elb')
        logger.info('elb: {}'.format(elb))
        cfg_elb_name = elb.get('lb_name')
        logger.info('cfg_elb_name: {}'.format(cfg_elb_name))
    
        if self.elb_enable=='yes':
           if self.elb_name:
               lb_name = self.elb_name
               if cfg_elb_name != self.elb_name:
                   reason = 'Configured ELB name does not match actual ELB name.'
                   raise Exception(reason)
           else:
               lb_name = cfg_elb_name
        else:
           lb_name = self.gateway_name
        logger.info('elb_enable: {}'.format(self.elb_enable))
        logger.info('lb_name: {}'.format(lb_name))

        logger.info('Begin adding VPN user...')
        response = create_vpn_user(
                                   url=self.base_url,
                                   CID=CID,
                                   vpc_id=vpc_server_id,
                                   username=self.vpn_username,
                                   gateway_name=lb_name,
                                   user_email=self.vpn_user_email)
        logger.info('End adding VPN user.')
        self.handle_api_error(response, raise_except=True)

        #Get VPN client config file
        logger.info('Begin getting VPN user cert...')
        logger.info('base_url: {}'.format(self.base_url))
        logger.info('vpc_server_id: {}'.format(vpc_server_id))
        logger.info('username: {}'.format(self.vpn_username))
        response = get_vpn_client_cert(
                                       url=self.base_url,
                                       CID=CID,
                                       vpc_id=vpc_server_id,
                                       lb_name=lb_name,
                                       username=self.vpn_username)
        try:
            response_json = response.json()
            cert = response_json['results']
        except Exception as e:
            reason = 'get_vpn_client_cert failed. ' + str(e)
            logger.error(reason)
            raise Exception(reason) 

        logger.info('cert: {}'.format(cert))
        cert_file = CONFIG_PATH + self.vpn_username + OVPN_EXT
        logger.info('cert_file: {}'.format(cert_file))
        with open(cert_file, 'w') as f:
            f.write(cert)
        logger.info('End getting VPN user cert')

        cmd = 'sudo scp -i ' + private_key + ' ' + SSH_OPTS_FLG + \
              cert_file + ' ubuntu@' + aws_cfg['inst_public_ip'] \
              + ':~'
        logger.info('cmd: {}'.format(cmd))
        os.system(cmd)

        cmd = 'sudo openvpn --daemon --config ' + '~/' + self.vpn_username + OVPN_EXT 
        logger.info('cmd: {}'.format(cmd))
        result = ssh.exec_cmd(cmd, ignore_exit_status=True)
        logger.info('ssh result {}'.format(result))

        time.sleep(120)
        cmd = 'ping -c 2 -w 2 ' + aws_cfg_server['inst_private_ip']
        logger.info('cmd: {}'.format(cmd))
        result = ssh.exec_cmd(cmd, ignore_exit_status=True)
        logger.info('ssh result {}'.format(result))
        if '100% packet loss' in str(result['stdout']):
            logger.error('Ping failed')
        else:
            logger.info('Ping success')
        ssh.close()

    def delete_client_instance_vpc(self):
        #Delete client instance and vpc
        logger.info('Begin deleting client instance and vpc...')
        cfg_file_client = CONFIG_PATH + self.vpc_client_tag + CFG_EXT
        client_ssh = CONFIG_PATH + self.vpc_client_tag + SSHKEY_EXT
        with open(cfg_file_client, 'r') as f:
            aws_cfg = json.load(f)
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

    def delete_server_instance_vpc(self):
        #Delete server instance and vpc
        logger.info('Begin deleting server instance and vpc ...')
        cfg_file_server = CONFIG_PATH + self.vpc_server_tag + CFG_EXT
        server_ssh = CONFIG_PATH + self.vpc_server_tag + SSHKEY_EXT
        with open(cfg_file_server, 'r') as f:
            aws_cfg = json.load(f)
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

    def remove_avx_openvpn(self):
        reason = ''

        # Login controller
        logger.info('Begin login controller...')
        response = login_GET_method(
                                    url=self.base_url,
                                    username=self.controller_username,
                                    password=self.controller_password)
        logger.info('End login controller.')
        resp_json = response.json()
        logger.info('resp_json: {}'.format(resp_json))
        if resp_json['return']:
            CID = resp_json['CID']
            logger.info(msg="CID: " + CID)
        else:
            reason = reason + self.handle_api_error(response)


        # delete user
        logger.info('Begin deleting VPN user...')
        logger.info('username: {}'.format(self.vpn_username))
        cfg_file_server = CONFIG_PATH + self.vpc_server_tag + CFG_EXT
        with open(cfg_file_server, 'r') as f:
            aws_cfg = json.load(f)
            logger.info('vpc_id: {}'.format(aws_cfg['vpc_id']))

        response = delete_vpn_user(
                                   url=self.base_url,
                                   CID=CID,
                                   vpc_id=aws_cfg['vpc_id'],
                                   username=self.vpn_username)
        logger.info('End deleting VPN user.')
        reason = reason + self.handle_api_error(response)

        cmd = 'sudo rm ' + CONFIG_PATH + self.vpn_username + OVPN_EXT
        logger.info('cmd: {}'.format(cmd))
        os.system(cmd)

        # delete Aviatrix VPN gateway
        logger.info('Begin deleting Aviatrix VPN gateway...')
        response = delete_gateway_api(
                                      url=self.base_url,
                                      CID=CID,
                                      cloud_type=self.cloud_type,
                                      gateway_name=self.gateway_name,
                                      max_retry=10)
        logger.info('End deleting Aviatrix VPN gateway.')
        reason = reason + self.handle_api_error(response)

        # delete account
        logger.info('Begin deleting Aviatrix access account...')
        logger.info('account_name: {}'.format(self.account_name))
        response = delete_cloud_account(
                                        url=self.base_url,
                                        CID=CID,
                                        account_name = self.account_name)
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

    vpn = VPN(argv)
    if 'create' in argv[2]:
        ret, reason = vpn.validate_input(argv)

        if not ret:
            logger.error(reason)
            return
    if 'create' in argv[2]:
        try:
            vpn.build_avx_openvpn()
            result['create_return'] = True
            result['create_results'] = 'AWS Create VPN successful.'
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
            ret = vpn.remove_avx_openvpn()
            if not ret:
                result['delete_return'] = True
                result['delete_results'] = 'AWS Delete VPN successful.'
            else:
                result['delete_return'] = False
                result['delete_results'] = 'AWS Delete VPN Failed. ' + ret
        except Exception as e:
            reason = str(e)
            logger.error(reason)
            logger.error(str(traceback.format_exc()))
            result['delete_return'] = False
            result['delete_results'] = 'AWS Delete VPN Failed. ' + reason
    write_config_file(file_path=RESULT_PATH, cfg=result)
    

if __name__ == "__main__":
    main(sys.argv)
