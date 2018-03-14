#!/usr/bin/python3
# -*- coding: UTF-8 -*-


"""
Description:
    Delete the Aviatrix-Cloud-Controller Virtual Machine Instance which is created by "create_aviatrix_cloud_controller.py"


Author:
    Ryan Liu - Aviatrix System

"""


import boto3
import datetime
import json
import paramiko
import logging
import os
import requests
import traceback
import time

from urllib3.exceptions import NewConnectionError
from urllib3.exceptions import MaxRetryError
from requests.exceptions import ConnectionError

from lib.aws.ec2 import disassociate_address
from lib.aws.ec2 import release_address
from lib.aws.ec2 import terminate_instances
from lib.aws.ec2 import delete_security_group
from lib.aws.ec2 import delete_key_pair
from lib.aws.ec2 import disassociate_route_table
from lib.aws.ec2 import delete_route_table
from lib.aws.ec2 import detach_igw_from_vpc
from lib.aws.ec2 import delete_igw
from lib.aws.ec2 import delete_subnet
from lib.aws.ec2 import delete_vpc

from lib.aviatrix.initial_setup import login
from lib.aviatrix.initial_setup import login_GET_method

from lib.util.util import set_logger
from lib.util.util import read_config_file_to_py_dict
from lib.util.util import run_completion_notification
from lib.util.util import print_exception_wall_beg
from lib.util.util import print_exception_wall_end


##### Step 00: Script Config
path_to_result_file = "./result/result.json"
path_to_log_file    = "./result/log_history.txt"


##### Step 01-a: Read .json file into Python dictionary
result_config = read_config_file_to_py_dict(path_to_result_file)


##### Step 02-a: Read configuration
project_code            = result_config["Script_Control"]["project_code"]
script_log_file_enabled = result_config["Script_Control"]["script_log_file_enabled"]
notification_enabled    = result_config["Script_Control"]["notification_enabled"]
admin_password          = result_config["UCC"]["admin_password"]
account_users           = result_config["UCC"]["Account_Users"]
region                  = result_config["AWS"]["region"]
eip_association_id      = result_config["AWS"]["eip_association_id"]
eip_id                  = result_config["AWS"]["eip_id"]
instance_id             = result_config["AWS"]["instance_id"]
key_pair_name           = result_config["AWS"]["key_pair_name"]
rtb_association_id      = result_config["AWS"]["rtb_association_id"]
route_table_id          = result_config["AWS"]["route_table_id"]
igw_id                  = result_config["AWS"]["igw_id"]
security_group_id       = result_config["AWS"]["security_group_id"]
subnet_id               = result_config["AWS"]["subnet_id"]
vpc_id                  = result_config["AWS"]["vpc_id"]


try:
    ##### Step 03: Setup 'logger' object (from logging module)
    logger = set_logger(logger_name=__name__,
                        logging_level=logging.INFO,
                        log_file_enabled=script_log_file_enabled,
                        path_to_log_file=path_to_log_file,
                        log_file_mode="a")


    print_wall_beg(logger=logger)


    ##### Step 04: Delete all Cloud-Accounts in Aviatrix Cloud Controller
    pass



    try:
        ##### Disassociate EIP from instance
        disassociate_address(logger=logger, region=region, eip_association_id=eip_association_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Release EIP
        release_address(logger=logger, region=region, eip_id=eip_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Delete UCC
        terminate_instances(logger=logger, region=region, instance_id_list=[instance_id])
        time.sleep(60)  #################################################################################################### need to find a better way to wait until ec2-instance deletion is done instead of explicit wait
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)



    try:
        ##### Delete Security-Group
        delete_security_group(logger=logger,
                              region=region,
                              security_group_id=security_group_id,
                              security_group_name=project_code)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Delete Key-Pair
        delete_key_pair(logger=logger, region=region, key_pair_name=key_pair_name)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Disassociate Route-Table from Subnet
        disassociate_route_table(logger=logger, region=region, route_table_association_id=rtb_association_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Delete Route-Table
        delete_route_table(logger=logger, region=region, route_table_id=route_table_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Detach IGW from VPC
        detach_igw_from_vpc(logger=logger, region=region, igw_id=igw_id, vpc_id=vpc_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        #### Delete IGW
        delete_igw(logger=logger, region=region, igw_id=igw_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)



    try:
        ##### Delete Subnet
        delete_subnet(logger=logger, region=region, subnet_id=subnet_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)





    try:
        ##### Delete VPC
        delete_vpc(logger=logger, region=region, vpc_id=vpc_id)
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(msg=tracekback_msg)

except Exception as e:
    tracekback_msg = traceback.format_exc()
    logger.info(msg=tracekback_msg)

finally:
    if notification_enabled:
        run_completion_notification(logger=logger)

    timestamp_end = "{0:%Y-%m-%d_%H-%M-%S}".format(datetime.datetime.now())
    logger.info(msg="ENDED: " + timestamp_end)
    print_wall_end(logger=logger)

