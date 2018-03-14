#!/usr/bin/python3
# -*- coding: UTF-8 -*-


"""
Description:
    Create an Aviatrix-Cloud-Controller Virtual Machine Instance in the Cloud (AWS)


Prerequisites:
    * Complete the .json file -> ./config/user_config.json
        - Make sure region matches the correct AMI-ID

    * If you wish to use an existing AWS-Key-Pair(RSA.pem file), you need to copy the file to ./result/my_RSA_key.pem

    * "subnet_availability_zone" is optional


More INFO:
    * After a script is completed, it will run a notification (make 2 beeps and adjust screen brightness)

    * ANY feedback is greatly appreciated. (coding style, bug/error, etc...)

    * If you like this script, click the [Like] button


Author:
    Ryan Liu - Aviatrix System

"""


import boto3
import datetime
import json
import logging
import os
import paramiko
import requests
import traceback
import time

from urllib3.exceptions import NewConnectionError
from urllib3.exceptions import MaxRetryError
from requests.exceptions import ConnectionError

from lib.aws.account import get_aws_account_id

from lib.aws.iam import create_aviatrix_role_ec2
from lib.aws.iam import create_aviatrix_role_app

from lib.aws.ec2 import create_vpc
from lib.aws.ec2 import create_name_tag
from lib.aws.ec2 import create_subnet
from lib.aws.ec2 import create_igw
from lib.aws.ec2 import attach_igw_to_vpc
from lib.aws.ec2 import create_route_table
from lib.aws.ec2 import associate_route_table_to_subnet
from lib.aws.ec2 import create_route
from lib.aws.ec2 import create_security_group
from lib.aws.ec2 import authorize_security_group_ingress
from lib.aws.ec2 import create_key_pair
from lib.aws.ec2 import run_instance
from lib.aws.ec2 import describe_instance_status
from lib.aws.ec2 import allocate_eip
from lib.aws.ec2 import associate_address
from lib.aws.ec2 import associate_iam_instance_profile_to_ec2_instance

from lib.aviatrix.initial_setup import get_server_status_code
from lib.aviatrix.initial_setup import login
from lib.aviatrix.initial_setup import login_GET_method
from lib.aviatrix.initial_setup import set_admin_email_GET
from lib.aviatrix.initial_setup import set_admin_email
from lib.aviatrix.initial_setup import change_password_2_6_GET
from lib.aviatrix.initial_setup import change_password
from lib.aviatrix.initial_setup import run_initial_setup
from lib.aviatrix.initial_setup import set_customer_id
from lib.aviatrix.initial_setup import get_cloud_type

from lib.aviatrix.account import create_cloud_account

from lib.util.util import set_logger
from lib.util.util import read_config_file_to_py_dict
from lib.util.util import write_py_dict_to_config_file
from lib.util.util import run_completion_notification
from lib.util.util import print_wall_beg
from lib.util.util import print_wall_end
from lib.util.util import print_exception_wall_beg
from lib.util.util import print_exception_wall_end


timestamp_start = "{0:%Y-%m-%d_%H-%M-%S}".format(datetime.datetime.now())

##### Step 00: Script Config
path_to_aws_global_config_file      = "config_global/aws.config"
path_to_aviatrix_global_config_file = "config_global/aviatrix.config"  # This script does not use this file. This line is just for demo purpose.
path_to_user_config_file            = "./config/user_config.json"
path_to_result_file                 = "./result/result.json"
path_to_log_file                    = "./result/log_history.txt"


##### Step 01-a: Read .json file into Python dictionary
user_config = read_config_file_to_py_dict(path_to_user_config_file)
result      = read_config_file_to_py_dict(path_to_result_file)


### Step 01-b: Script Control
project_code = user_config["Script_Control"]["project_code"]
script_log_file_enabled          = user_config["Script_Control"]["script_log_file_enabled"]
keep_aviatrix_iam_roles_policies = user_config["Script_Control"]["keep_aviatrix_iam_roles_policies"]
notification_enabled             = user_config["Script_Control"]["notification_enabled"]

result["Script_Control"]["project_code"]                     = project_code
result["Script_Control"]["script_log_file_enabled"]          = script_log_file_enabled
result["Script_Control"]["keep_aviatrix_iam_roles_policies"] = keep_aviatrix_iam_roles_policies
result["Script_Control"]["notification_enabled"]             = notification_enabled


##### Step 02-a: Read configuration
region               = user_config["AWS"]["region"]
vpc_cidr             = user_config["AWS"]["vpc_cidr"]
subnet_cidr          = user_config["AWS"]["subnet_cidr"]
availability_zone    = user_config["AWS"]["subnet_availability_zone"]
ami_id               = user_config["AWS"]["ami_id"]
is_BYOL              = user_config["AWS"]["is_BYOL"]
instance_type        = user_config["AWS"]["instance_type"]
create_new_key       = user_config["AWS"]["create_new_key"]
admin_password       = user_config["UCC"]["admin_password"]
admin_email          = user_config["UCC"]["admin_email"]
aviatrix_customer_id = user_config["UCC"]["customer_id"]
users                = user_config["UCC"]["Account_Users"]


##### Step 02-b: Collect result and write to result file
result["Script_Control"]["project_code"]            = project_code
result["Script_Control"]["script_log_file_enabled"] = script_log_file_enabled
result["Script_Control"]["notification_enabled"]    = notification_enabled
result["AWS"]["region"]                             = region


try:
    ##### Step 03: Setup 'logger' object (from logging module)
    logger = set_logger(logger_name=__name__,
                        logging_level=logging.INFO,
                        log_file_enabled=True,
                        path_to_log_file=path_to_log_file,
                        log_file_mode="w")


    print_wall_beg(logger=logger)


    ##### Step 02-b: Collect result and write to result file
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 04: Create EC2 Role
    ec2_role_created_by_script, instance_profile_arn = create_aviatrix_role_ec2(logger=logger)
    result["AWS"]["ec2_role_created_by_script"] = ec2_role_created_by_script
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)

    logger.info(msg="EC2 Role created by script? " + str(ec2_role_created_by_script))


    ##### Step 05: Create APP Role
    aws_account_id = get_aws_account_id(logger=logger)  # Get AWS Account ID
    app_role_created_by_script = create_aviatrix_role_app(logger=logger, aws_account_id=aws_account_id)
    result["AWS"]["aws_account_id"]             = aws_account_id
    result["AWS"]["app_role_created_by_script"] = app_role_created_by_script
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 06-a: Create VPC
    vpc_id = create_vpc(logger=logger, region=region, cidr=vpc_cidr)
    result["AWS"]["vpc_id"] = vpc_id
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 06-b: Create Name-Tag for VPC
    create_name_tag(logger=logger, region=region, resource=vpc_id, name=project_code)


    ##### Step 07-a: Create Subnet
    subnet_id = create_subnet(logger=logger, region=region, vpc_id=vpc_id, availability_zone=availability_zone, cidr=subnet_cidr)
    result["AWS"]["subnet_id"] = subnet_id
    write_py_dict_to_config_file(py_dict=result, path_to_file=path_to_result_file)


    ##### Step 07-b: Create Name-Tag for subnet
    create_name_tag(logger=logger, region=region, resource=subnet_id, name=project_code)


    ##### Step 08-a: Create IGW
    igw_id = create_igw(logger=logger, region=region)
    result["AWS"]["igw_id"] = igw_id
    write_py_dict_to_config_file(py_dict=result, path_to_file=path_to_result_file)


    ##### Step 08-b: Create Name-Tag for IGW
    create_name_tag(logger=logger, region=region, resource=igw_id, name=project_code)


    ##### Step 09: Attach IGW to VPC
    attach_igw_to_vpc(logger=logger, region=region, igw_id=igw_id, vpc_id=vpc_id)


    ##### Step 10-a: Create Route table
    route_table_id = create_route_table(logger=logger, region=region, vpc_id=vpc_id)
    result["AWS"]["route_table_id"] = route_table_id
    write_py_dict_to_config_file(py_dict=result, path_to_file=path_to_result_file)


    ##### Step 11-b: Create Name-Tag for route table
    create_name_tag(logger=logger, region=region, resource=route_table_id, name=project_code)


    ##### Step 12: Associate Route table to subnet
    rtb_association_id = associate_route_table_to_subnet(logger=logger, region=region, route_table_id=route_table_id, subnet_id=subnet_id)
    result["AWS"]["rtb_association_id"] = rtb_association_id
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 13: Create Default Route to Subnet's Route-Table
    create_route(logger=logger, region=region, route_table_id=route_table_id, destnation_cidr="0.0.0.0/0", igw_id=igw_id)


    ##### Step 14-a: Create Security-Group
    security_group_id = create_security_group(logger=logger, 
                                              region=region,
                                              vpc_id=vpc_id,
                                              security_group_name=project_code,
                                              description=project_code)
    result["AWS"]["security_group_id"] = security_group_id
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 14-b: Create Name-Tag for route table
    create_name_tag(logger=logger, region=region, resource=route_table_id, name=project_code)


    ##### Step 15-1: Authorize Security Group Ingress (HTTPS)
    authorize_security_group_ingress(logger=logger, 
                                     region=region,
                                     security_group_id=security_group_id,
                                     security_group_name=project_code,
                                     ip_protocal="tcp",
                                     port_range_from=443,
                                     port_range_to=443,
                                     source_ip_cidr="0.0.0.0/0"
                                     )


    ##### Step 15-2: Authorize Security Group Ingress (SSH)
    authorize_security_group_ingress(logger=logger, 
                                     region=region,
                                     security_group_id=security_group_id,
                                     security_group_name=project_code,
                                     ip_protocal="tcp",
                                     port_range_from=22,
                                     port_range_to=22,
                                     source_ip_cidr="0.0.0.0/0"
                                     )


    if create_new_key:
        ##### Step 16-A: Create key pair (pem file)
        key_pair_name = project_code + "-" + timestamp_start
        private_key = create_key_pair(logger = logger,region=region, key_pair_name=key_pair_name)
        result["AWS"]["key_pair_name"] = key_pair_name
        result["AWS"]["private_key"] = private_key
        write_py_dict_to_config_file(logger = logger,py_dict=result, path_to_file=path_to_result_file)
        logger.info(msg="\n" + private_key + "\n")

        ##### Step 16-b: Write to a file
        path_to_rsa_key_file = "./result/key-" + timestamp_start + ".pem"
        with open(path_to_rsa_key_file, "w") as file_output_stream:
            file_output_stream.write(private_key)

    else:
        ##### Step 16-A: Use existing key pair (pem file)
        key_pair_name = user_config["AWS"]["existing_key_pair_name"]
        private_key   = user_config["AWS"]["private_key"]

    # END if-else


    ##### Step 17: Create UCC VM
    ucc_instance_id, ucc_private_ip = run_instance(logger=logger,
                                                   region=region,
                                                   ami_id=ami_id,
                                                   subnet_id=subnet_id,
                                                   instance_type=instance_type,
                                                   vm_name=project_code,
                                                   key_pair_name=key_pair_name,
                                                   security_group_id=security_group_id
                                                   # network_interface_id=network_interface_id
                                                   )
    result["AWS"]["instance_id"] = ucc_instance_id
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 18: Wait until UCC is ready
    logger.info(msg="START: Wait until UCC instance is ready")

    time.sleep(30)
    instance_id_list = list()
    instance_id_list.append(ucc_instance_id)
    instance_state, instance_system_status = describe_instance_status(logger=logger, 
                                                                      region=region,
                                                                      instance_id_list=instance_id_list)
    while instance_state != "running" and instance_system_status != "initializing":
        time.sleep(5)
        logger.info(msg="    Current UCC status is: " + instance_state)

        instance_state, instance_system_status = describe_instance_status(logger=logger, 
                                                                          region=region,
                                                                          instance_id_list=instance_id_list)
    logger.info(msg="ENDED: Wait until UCC instance is ready")


    ##### Step 19-a: Allocate a new EIP
    eip_id, ucc_public_ip = allocate_eip(logger=logger, region=region)
    result["AWS"]["eip_id"] = eip_id
    result["AWS"]["ucc_public_ip"] = ucc_public_ip
    write_py_dict_to_config_file(logger=logger, py_dict=result, path_to_file=path_to_result_file)


    ##### Step 19-b: Create Name-Tag for EIP
    create_name_tag(region=region, resource=eip_id, name=project_code)


    ##### Step 20: Associate EIP to UCC EC2 Instance
    eip_association_id = associate_address(region=region, eip=ucc_public_ip, instance_id=ucc_instance_id)
    result["AWS"]["eip_association_id"] = eip_association_id
    write_py_dict_to_config_file(py_dict=result, path_to_file=path_to_result_file)


    ##### Step 21: Associate IAM-Instance-Profile to a EC2 Instance
    instance_profile_association_id_with_ec2_instance = associate_iam_instance_profile_to_ec2_instance(
                                                                    logger=logger,
                                                                    region=region,
                                                                    iam_instance_profile_arn=instance_profile_arn,
                                                                    ec2_instance_id=ucc_instance_id
                                                                    )
    result["AWS"]["instance_profile_association_id_with_ec2_instance"] = instance_profile_association_id_with_ec2_instance
    write_py_dict_to_config_file(py_dict=result, path_to_file=path_to_result_file)


    ##### Step 22: Wait until UCC apache2 server is ready
    logger.info(msg="\nSTART: Wait until UCC apache2 server is ready...")

    api_url = "https://" + ucc_public_ip + "/v1/api"
    code = get_server_status_code(url=api_url)
    while code is not 200:
        time.sleep(5)
        code = get_server_status_code(url=api_url)

    logger.info(msg="\n    Succeed! UCC apache2 server is ready...")
    logger.info(msg="\nENDED: Wait until UCC apache2 server is ready...")


    ##### Step 23: Login with Instance's Private IP as Password && Get CID
    response = login_GET_method(url=api_url, username="admin", password=ucc_private_ip)
    py_dict = response.json()
    if py_dict["return"]:
        CID = py_dict["CID"]
    logger.info(msg="CID: " + CID)


    ##### Step 24: Setup Admin Email
    response = set_admin_email_GET(url=api_url, CID=CID, admin_email=admin_email)
    py_dict = response.json()
    logger.info(msg=py_dict)


    ##### Step 25: Change Password
    response = change_password_2_6_GET(logger=logger, url=api_url, CID=CID, account_name="admin", username="admin",
                                       password=ucc_private_ip, new_password=admin_password)
    py_dict = response.json()
    logger.info(msg=py_dict)


    ##### Step 26: Re-Login
    response = login_GET_method(logger=logger, url=api_url, username="admin", password=admin_password)
    py_dict = response.json()
    if py_dict["return"]:
        CID = py_dict["CID"]
    logger.info(msg="CID: " + CID)


    ##### Step 27: Run Initial-Setup
    response = run_initial_setup(logger=logger, url=api_url, CID=CID)
    py_dict = response.json()
    logger.info(msg=py_dict)


    ##### Step xx: Wait until UCC apache2 server is ready  ############################################################# No use....
    logger.info(msg="\nSTART: Wait until UCC apache2 server is ready...")

    api_url = "https://" + ucc_public_ip + "/v1/api"
    code = get_server_status_code(logger=logger, url=api_url)
    while code is not 200:
        time.sleep(5)
        code = get_server_status_code(logger=logger, url=api_url)

    logger.info(msg="\n    Succeed! UCC apache2 server is ready...")
    logger.info(msg="\nENDED: Wait until UCC apache2 server is ready...")


    ########################################################################################################################## Need to optimise
    logger.info(msg="\nSTART: Wait for 180 seconds to finish initial setup process...")
    time.sleep(180)
    logger.info(msg="ENDED: Wait for 180 seconds to finish initial setup process...\n")


    ##### Step xx: Re-Login
    response = login_GET_method(logger=logger, url=api_url, username="admin", password=admin_password)
    py_dict = response.json()
    if py_dict["return"]:
        CID = py_dict["CID"]
    logger.info(msg="CID: " + CID)


    ##### Step xx: Set Aviatrix Customer ID
    response = set_customer_id(logger=logger, url=api_url, CID=CID, customer_id=aviatrix_customer_id)
    py_dict = response.json()
    logger.info(msg=py_dict)


    ##### Step FINAL: Print Result
    print_wall_beg(logger=logger)

    logger.info(msg="Final Result:")
    logger.info(msg="--------------------------------------------------------------\n")
    logger.info(msg="Region                    : " + region)
    logger.info(msg="AMI ID                    : " + ami_id)
    logger.info(msg="Instance ID               : " + ucc_instance_id)
    logger.info(msg="Controller URL            : " + "https://" + ucc_public_ip)
    logger.info(msg="Controller Private IP     : " + ucc_private_ip)
    logger.info(msg="Controller admin password : " + admin_password)

except Exception as e:
    print_exception_wall_beg(logger=logger)
    tracekback_msg = traceback.format_exc()
    logger.info(msg=tracekback_msg)
    print_exception_wall_end(logger=logger)

finally:
    if notification_enabled:
        run_completion_notification(logger=logger)

    timestamp_end = "{0:%Y-%m-%d_%H-%M-%S}".format(datetime.datetime.now())
    logger.info(msg="ENDED: " + timestamp_end)
    print_wall_end(logger=logger)
