# Copyright (c) 2018, Aviatrix Systems, Inc.

#######################################################################################
#   Reference script for testing Aviatrix Encrypted Peering between two VPCs
#1. Create VPC1 with an Ubuntu user instance1
#2. Create VPC2 with an Ubuntu user instance2
#3. Setup Aviatrix access account
#4. Launch Aviatrix gateway1 in VPC1
#5. Launch Aviatrix gateway2 in VPC2
#6. Create Encrypted Peering between gateway1 and gateway2.
# Pings between instance1 and instance2. Verify pings pass
#7. Delete Encrypted Peering between gateway1 and gateway2.
# Pings between instance1 and instance2. Verify pings fail
#8. Delete Aviatrix gateway1 in VPC1
#9. Delete Aviatrix gateway2 in VPC2
#10. Delete VPC1 and instance1
#11. Delete VPC2 and instance2
#######################################################################################

import os
import logging
import json
import sys
import time
import traceback

from Aviatrix_API_Python_Scripts.projects.encrypted_peering.constants import CONFIG_PATH, \
    LOG_PATH, CFG_EXT, SSHKEY_EXT, RESULT_PATH

from Aviatrix_API_Python_Scripts.lib.aws.ec2 import aws_create_vpc, aws_delete_vpc
from Aviatrix_API_Python_Scripts.lib.aviatrix.account import create_cloud_account, delete_cloud_account
from Aviatrix_API_Python_Scripts.lib.aviatrix.gateway import create_gateway, get_gateway_info, \
    delete_gateway_api
from Aviatrix_API_Python_Scripts.lib.util.util import set_logger, read_config_file, \
    write_config_file, delete_files_in_directory, ping_from_instance
from Aviatrix_API_Python_Scripts.lib.util.ssh_session import SSHSession
from Aviatrix_API_Python_Scripts.lib.aviatrix.initial_setup import login_GET_method
from Aviatrix_API_Python_Scripts.lib.aviatrix.encrypted_peering import create_encrypted_peering, \
    delete_encrypted_peering

logger = logging.getLogger(__name__)


class EncryptedPeering(object):
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
        self.region_vpc1 = cfg['region_vpc1']
        self.region_vpc2 = cfg['region_vpc2']
        self.vpc1_cidr = cfg['vpc1_cidr']
        self.vpc2_cidr = cfg['vpc2_cidr']
        self.vpc1_subnet_cidr = cfg['vpc1_subnet_cidr']
        self.vpc2_subnet_cidr = cfg['vpc2_subnet_cidr']
        self.vpc1_tag = cfg['vpc1_tag']
        self.vpc2_tag = cfg['vpc2_tag']
        self.gateway1_size = cfg['gateway1_size']
        self.gateway2_size = cfg['gateway2_size']
        self.gateway1_name = cfg['gateway1_name']
        self.gateway2_name = cfg['gateway2_name']
        self.base_url = "https://" + self.ucc_public_ip + "/v1/api"

        self.cfg_file_vpc1 = CONFIG_PATH + self.vpc1_tag + CFG_EXT
        self.cfg_file_vpc2 = CONFIG_PATH + self.vpc2_tag + CFG_EXT
        self.private_key = CONFIG_PATH + self.vpc1_tag + SSHKEY_EXT
        self.aws_cfg_vpc1 = []
        self.aws_cfg_vpc2 = []
        self.cid = ''

        # Login controller to retrieve CID
        logger.info('Begin login controller...')
        response = login_GET_method(
            url=self.base_url,
            username=self.controller_username,
            password=self.controller_password)
        resp_json = response.json()
        if resp_json["return"]:
            self.cid = resp_json["CID"]
            logger.info(msg="CID: " + self.cid)
        logger.info('End login controller.')
        self.handle_api_error(response, raise_except=True)

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
        if not self.region_vpc1:
            reason = 'region_vpc1 missing'
            return False, reason
        if not self.region_vpc2:
            reason = 'region_vpc2 missing'
            return False, reason
        if not self.vpc1_tag:
            reason = 'vpc1_tag missing'
            return False, reason
        if not self.vpc2_tag:
            reason = 'vpc2_tag missing'
            return False, reason
        if not self.vpc1_cidr:
            reason = 'vpc1_cidr missing'
            return False, reason
        if not self.vpc2_cidr:
            reason = 'vpc2_cidr missing'
            return False, reason
        if not self.vpc1_subnet_cidr:
            reason = 'vpc1_subnet_cidr missing'
            return False, reason
        if not self.vpc2_subnet_cidr:
            reason = 'vpc2_subnet_cidr missing'
            return False, reason
        if not self.gateway1_size:
            reason = 'gateway1_size missing'
            return False, reason
        if not self.gateway2_size:
            reason = 'gateway2_size missing'
            return False, reason
        if not self.gateway1_name:
            reason = 'gateway1_name missing'
            return False, reason
        if not self.gateway2_name:
            reason = 'gateway2_name missing'
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

    def build_vpc1(self):
        # create vpc1 with one ubuntu instance
        logger.info('Begin creating VPC1 and instance ...')
        aws_create_vpc(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_vpc1,
                       vpc_cidr=self.vpc1_cidr,
                       vpc_name_tag=self.vpc1_tag,
                       subnet_cidr=self.vpc1_subnet_cidr,
                       create_instance=True,
                       cfg_file=CONFIG_PATH)
        logger.info('End creating VPC1 and instance .')

        return True

    def build_vpc2(self):
        # create vpc2 with one ubuntu instance
        logger.info('Begin creating VPC2 and instance ...')
        aws_create_vpc(aws_access_key_id=self.aws_access_key_id,
                       aws_secret_access_key=self.aws_secret_access_key,
                       region_name=self.region_vpc2,
                       vpc_cidr=self.vpc2_cidr,
                       vpc_name_tag=self.vpc2_tag,
                       subnet_cidr=self.vpc2_subnet_cidr,
                       create_instance=True,
                       cfg_file=CONFIG_PATH)
        logger.info('End creating VPC2 and instance .')

        return True

    def create_access_account(self):
        # create Aviatrix cloud access account
        logger.info('Begin creating Aviatrix cloud access account...')
        logger.info('account_name: {}'.format(self.account_name))
        logger.info('account_password: {}'.format(self.account_password))
        logger.info('cloud_type: {}'.format(self.cloud_type))

        response = create_cloud_account(
            url=self.base_url,
            CID=self.cid,
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

        return True

    def create_gateway1(self):
        logger.info('Begin launching Aviatrix gateway1 in VPC1...')

        self.aws_cfg_vpc1 = read_config_file(file_path=self.cfg_file_vpc1)
        vpc_server_id = self.aws_cfg_vpc1['vpc_id']
        subnet_name = self.vpc1_subnet_cidr + '~~' + \
                      self.region_vpc1 + '~~' + self.vpc1_tag + '-public'

        response = create_gateway(
            url=self.base_url,
            CID=self.cid,
            avx_cloud_account_name=self.account_name,
            cloud_type=self.cloud_type,
            vpc_region=self.region_vpc1,
            vpc_id=vpc_server_id,
            subnet_name=subnet_name,
            gateway_size=self.gateway1_size,
            gateway_name=self.gateway1_name,
            allocate_new_eip="on",
            vpn_access="no")
        logger.info('End launching Aviatrix gateway1 in VPC1.')

        self.handle_api_error(response, raise_except=True)

        logger.info('Begin getting Aviatrix gateway1 info...')
        response = get_gateway_info(
            url=self.base_url,
            CID=self.cid,
            gateway_name=self.gateway1_name)
        logger.info('End getting Aviatrix gateway1 info.')
        self.handle_api_error(response, raise_except=True)
        resp = response.json()
        cfg_gw = resp['results']
        logger.info('cfg_gw: {}'.format(cfg_gw))

        return cfg_gw

    def create_gateway2(self):
        logger.info('Begin launching Aviatrix gateway2 in VPC2...')

        self.aws_cfg_vpc2 = read_config_file(file_path=self.cfg_file_vpc2)
        vpc_server_id = self.aws_cfg_vpc2['vpc_id']
        subnet_name = self.vpc2_subnet_cidr + '~~' + \
                      self.region_vpc2 + '~~' + self.vpc2_tag + '-public'

        response = create_gateway(
            url=self.base_url,
            CID=self.cid,
            avx_cloud_account_name=self.account_name,
            cloud_type=self.cloud_type,
            vpc_region=self.region_vpc2,
            vpc_id=vpc_server_id,
            subnet_name=subnet_name,
            gateway_size=self.gateway2_size,
            gateway_name=self.gateway2_name,
            allocate_new_eip="on",
            vpn_access="no")
        logger.info('End launching Aviatrix gateway2 in VPC2.')

        self.handle_api_error(response, raise_except=True)

        logger.info('Begin getting Aviatrix gateway2 info...')
        response = get_gateway_info(
            url=self.base_url,
            CID=self.cid,
            gateway_name=self.gateway2_name)
        logger.info('End getting Aviatrix gateway2 info.')
        self.handle_api_error(response, raise_except=True)
        resp = response.json()
        cfg_gw = resp['results']
        logger.info('cfg_gw: {}'.format(cfg_gw))

        return cfg_gw

    def create_encrypted_peering(self):
        logger.info('Begin creating encrypted peering between gateway1 and gateway2...')
        response = create_encrypted_peering(logger, self.base_url, self.cid,
                                            self.gateway1_name, self.gateway2_name)
        logger.info('End creating encrypted peering between gateway1 and gateway2.')
        self.handle_api_error(response, raise_except=True)

        time.sleep(60)

        logger.info('SSH into the user instance at VPC1')
        vpc1_cfg = read_config_file(file_path=self.cfg_file_vpc1)
        vpc2_cfg = read_config_file(file_path=self.cfg_file_vpc2)
        ssh = SSHSession(vpc1_cfg['inst_public_ip'], 'ubuntu', ssh_key=self.private_key)

        logger.info('Ping from VPC1 to VPC2 WITH encrypted peering')
        ping_result = ping_from_instance(ssh, vpc2_cfg['inst_private_ip'])

        if not ping_result:
            logger.error('Test failed - Ping failed WITH encrypted peering')
            ssh.close()
            return False
        else:
            logger.info('Test passed - Ping succeeded WITH encrypted peering')
            ssh.close()
            return True

    def delete_encrypted_peering(self):
        logger.info('Begin deleting encrypted peering between gateway1 and gateway2...')
        response = delete_encrypted_peering(logger, self.base_url, self.cid,
                                            self.gateway1_name, self.gateway2_name)
        logger.info('End deleting encrypted peering between gateway1 and gateway2.')
        self.handle_api_error(response, raise_except=True)

        time.sleep(60)

        logger.info('SSH into the user instance at VPC1')
        vpc1_cfg = read_config_file(file_path=self.cfg_file_vpc1)
        vpc2_cfg = read_config_file(file_path=self.cfg_file_vpc2)
        ssh = SSHSession(vpc1_cfg['inst_public_ip'], 'ubuntu', ssh_key=self.private_key)

        logger.info('Ping from VPC1 to VPC2 WITHOUT encrypted peering')
        ping_result = ping_from_instance(ssh, vpc2_cfg['inst_private_ip'])

        if not ping_result:
            logger.error('Test passed - Ping failed WITHOUT encrypted peering')
            ssh.close()
            return True
        else:
            logger.info('Test failed - Ping succeeded WITHOUT encryted peering')
            ssh.close()
            return False

    def delete_vpc1(self):
        # Delete user instance and vpc1
        logger.info('Begin deleting user instance and vpc1...')
        cfg_file_vpc1 = CONFIG_PATH + self.vpc1_tag + CFG_EXT
        with open(cfg_file_vpc1, 'r') as f:
            aws_cfg = json.load(f)
            logger.info('VPC1 vpc_id: {}'.format(aws_cfg["vpc_id"]))
            aws_delete_vpc(aws_access_key_id=self.aws_access_key_id,
                           aws_secret_access_key=self.aws_secret_access_key,
                           region_name=self.region_vpc1,
                           vpc_name_tag=self.vpc1_tag,
                           vpc_id=aws_cfg["vpc_id"])
        logger.info('End deleting user instance and vpc1.')

        return True

    def delete_vpc2(self):
        # Delete user instance and vpc2
        logger.info('Begin deleting user instance and vpc2...')
        cfg_file_vpc2 = CONFIG_PATH + self.vpc2_tag + CFG_EXT
        with open(cfg_file_vpc2, 'r') as f:
            aws_cfg = json.load(f)
            logger.info('VPC2 vpc_id: {}'.format(aws_cfg["vpc_id"]))
            aws_delete_vpc(aws_access_key_id=self.aws_access_key_id,
                           aws_secret_access_key=self.aws_secret_access_key,
                           region_name=self.region_vpc2,
                           vpc_name_tag=self.vpc2_tag,
                           vpc_id=aws_cfg["vpc_id"])
        logger.info('End deleting user instance and vpc2.')

        return True

    def delete_gateway1(self):
        # delete Aviatrix gateway1
        logger.info('Begin deleting Aviatrix gateway1...')
        response = delete_gateway_api(
            url=self.base_url,
            CID=self.cid,
            cloud_type=self.cloud_type,
            gateway_name=self.gateway1_name,
            max_retry=10)
        logger.info('End deleting Aviatrix gateway1.')
        reason = self.handle_api_error(response)

        return reason

    def delete_gateway2(self):
        # delete Aviatrix gateway2
        logger.info('Begin deleting Aviatrix gateway2...')
        response = delete_gateway_api(
            url=self.base_url,
            CID=self.cid,
            cloud_type=self.cloud_type,
            gateway_name=self.gateway2_name,
            max_retry=10)
        logger.info('End deleting Aviatrix gateway2.')
        reason = self.handle_api_error(response)

        return reason

    def delete_access_account(self):
        # delete access account
        logger.info('Begin deleting Aviatrix access account...')
        logger.info('account_name: {}'.format(self.account_name))
        response = delete_cloud_account(
            url=self.base_url,
            CID=self.cid,
            account_name=self.account_name)
        logger.info('End deleting Aviatrix access account.')
        reason = self.handle_api_error(response)

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
    if argv[2] != 'create' and argv[2] != 'delete' and argv[2] != 'create-delete':
        reason = argv[2] + ' not part of keyword create, delete, create-delete'
        logger.error(reason)

    return reason


def main(argv):
    logger = set_logger(path_to_log_file=LOG_PATH + 'test.log')
    result = {}

    reason = validate_args(argv)
    if reason:
        return

    peering = EncryptedPeering(argv)
    if 'create' in argv[2]:
        ret, reason = peering.validate_input(argv)

        if not ret:
            logger.error(reason)
            return

    if 'create' in argv[2]:
        logger.info("Delete all files under {}".format(CONFIG_PATH))
        delete_files_in_directory(CONFIG_PATH)

        logger.info("Delete all files under {}".format(LOG_PATH))
        delete_files_in_directory(LOG_PATH)

        try:
            logger.info("Create VPC1 with one Ubuntu user instance in VPC1")
            peering.build_vpc1()

            logger.info("Create VPC2 with one Ubuntu user instance in VPC2")
            peering.build_vpc2()
            
            logger.info("Create an access account at Controller")
            peering.create_access_account()

            logger.info("Create Aviatrix Gateway1 at VPC1")
            peering.create_gateway1()

            logger.info("Create Aviatrix Gateway2 at VPC2")
            peering.create_gateway2()

            logger.info("Create encrypted peering between Gateway1 and Gateway2 and verify pings pass")
            ret = peering.create_encrypted_peering()

            if ret:
                logger.info("Create Encrypted Peering - PASSED")
                result['create_return'] = True
                result['create_results'] = 'Create Encryped Peering - PASSED.'
            else:
                logger.error("Create Encrypted Peering - FAILED")
                result['create_return'] = False
                result['create_results'] = 'Create Encrypted Peering - FAILED.'
        except Exception as e:
            reason = str(e)
            logger.error(reason)
            logger.error(str(traceback.format_exc()))
            result['create_return'] = False
            result['create_results'] = reason

    if 'delete' in argv[2]:
        if argv[2] == 'create-delete':
            time.sleep(120)
        try:
            logger.info("Delete encrypted peering between Gateway1 and Gateway2 and verify pings fail")
            ret = peering.delete_encrypted_peering()

            logger.info("Delete Gateway1")
            peering.delete_gateway1()

            logger.info("Delete Gateway2")
            peering.delete_gateway2()

            logger.info("Delete VPC1")
            peering.delete_vpc1()

            logger.info("Delete VPC2")
            peering.delete_vpc2()
            
            logger.info("Delete the Access Account at Controller")
            peering.delete_access_account()

            if ret:
                result['delete_return'] = True
                result['delete_results'] = 'Delete Encrypted Peering - PASSED.'
            else:
                result['delete_return'] = False
                result['delete_results'] = 'Delete Encrypted Peering - FAILED.'
        except Exception as e:
            reason = str(e)
            logger.error(reason)
            logger.error(str(traceback.format_exc()))
            result['delete_return'] = False
            result['delete_results'] = 'Delete Encrypted Peering - FAILED.' + reason

    write_config_file(file_path=RESULT_PATH, cfg=result)


if __name__ == "__main__":
    main(sys.argv)

