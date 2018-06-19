"""
Objectives:
    This script demonstrates Aviatrix feature - FQDN Discovery.


Detail:
    This script does the following... (The following example is based on AWS)
    Step 01: Create a VPC in the cloud (AWS, Azure, GCE, etc...)
    Step 02: Create a Public Subnet and a Private Subnet
    Step 03: Create 1 EC2 instance in each subnet
    Step 04: Create


Prerequisites:
    *  Specify the credential (recommend using root credential to avoid failure due to cloud vendor API permission)  of cloud vendor in the file -> "config_global/aws_config.json
    *  Specify Aviatrix Controller related fields in the file -> "config_global/aviatrix_config.json"
    *  Specify all the fields in the file -> "projects/security/egress_control/fqdn_discovery/config_for_user.json"

"""


import os
import sys
import json
import datetime
import time
import logging
import traceback


timestamp_start = "{0:%Y-%m-%d_%H-%M-%S}".format(datetime.datetime.now())

PATH_TO_PROJECT_ROOT_DIR = "../../../../"  # (current pwd) fqdn_discovery -> egress_control -> security ->  projects -> Project Root Dir
sys.path.append(PATH_TO_PROJECT_ROOT_DIR)

from lib.util.util import set_logger
from lib.util.util import write_py_dict_to_config_file
from lib.aws.ec2 import create_aws_fqdn_test_environment_by_wizard
from lib.aviatrix.initial_setup import login
from lib.aviatrix.gateway import create_gateway
from lib.aviatrix.fqdn import start_fqdn_discovery
from lib.util.ssh_session import SSHSession
from lib.aviatrix.fqdn import get_fqdn_discovery_result


if __name__ == "__main__":
    try:
        ##### Step 00: Script Configuration
        path_to_user_config     = "./config/config_for_user.json"
        path_to_aws_config      = os.path.join(PATH_TO_PROJECT_ROOT_DIR, "config_global/aws_config.json")
        path_to_aviatrix_config = os.path.join(PATH_TO_PROJECT_ROOT_DIR, "config_global/aviatrix_config.json")
        path_to_log_file        = "./result/" + timestamp_start + ".log"
        path_to_teardown_config = "./config/config_for_teardown.json"


        ### Read configuration file
        with open(file=path_to_user_config, mode="r") as input_file_stream:
            config_user = json.load(fp=input_file_stream)

        ### Read configuration file
        with open(file=path_to_aws_config, mode="r") as input_file_stream:
            config_aws = json.load(fp=input_file_stream)

        ### Read configuration file
        with open(file=path_to_aviatrix_config, mode="r") as input_file_stream:
            config_avx = json.load(fp=input_file_stream)


        prefix_str                       = config_user["prefix_str"]

        cloud_type                       = config_user["cloud_type"]
        aws_access_key_id                = config_aws["AWS"]["Accounts"]["root"]["aws_access_key_id"]
        aws_secret_access_key            = config_aws["AWS"]["Accounts"]["root"]["aws_secret_access_key"]

        region_name                      = config_user["region_name"]
        vpc_name                         = prefix_str + "-vpc" + "-" + timestamp_start
        vpc_cidr                         = config_user["vpc_cidr"]

        public_subnet_name               = prefix_str + "-PubSub" + "-" + timestamp_start
        public_subnet_cidr               = config_user["public_subnet_cidr"]
        public_subnet_availability_zone  = config_user["public_subnet_availability_zone"]
        igw_name                         = prefix_str + "-igw" + "-" + timestamp_start
        non_main_rtb_name                = prefix_str + "-non-main-rtb" + "-" + timestamp_start

        private_subnet_name              = prefix_str + "-PriSub" + "-" + timestamp_start
        private_subnet_cidr              = config_user["private_subnet_cidr"]
        private_subnet_availability_zone = config_user["private_subnet_availability_zone"]
        main_rtb_name                    = prefix_str + "-main-rtb" + "-" + timestamp_start

        security_group_name              = prefix_str + "-sg" + "-" + timestamp_start
        security_group_rule_list         = ["SSH", "HTTPS", "HTTP", "All ICMP - IPv4"]
        default_security_group_name      = prefix_str + "-default-sg" + "-" + timestamp_start

        ##### We can only choose either Option A or Option B, NOT both
        create_new_key_pair              = True  # Currently we only support creating new key pair
        new_key_pair_name                = prefix_str + "-keypair" + "-" + timestamp_start
        path_to_save_new_pem_file        = "./result/" + new_key_pair_name + ".pem"

        ### Option B
        # old_key_pair_name                = "$$$-keypair-2018-05-30_16-37-10.pem"  # "old" means "existing"
        # path_to_old_pem_file             = PATH_TO_PROJECT_ROOT_DIR + "config/credential_files/" + old_key_pair_name

        ec2_ubuntu_ami_id                 = config_user["ec2_ubuntu_ami_id"]
        instance_type                     = "t2.micro"
        public_subnet_ec2_instance_name   = prefix_str + "-ubuntu_vm_in_pub_sub" + "-" + timestamp_start
        private_subnet_ec2_instance_name  = prefix_str + "-ubuntu_vm_in_pri_sub" + "-" + timestamp_start


        ##### Step 01: Setup logger
        logger = set_logger(
            logger_name=__name__,
            logging_level=logging.INFO,
            log_file_enabled=True,
            path_to_log_file=path_to_log_file,
            log_file_mode="w"
        )


        ##### Step 02: Build FQDN testing environment
        logger.info("START: Build FQDN testing environment")
        resources_config = create_aws_fqdn_test_environment_by_wizard(
            logger=logger,
            # resources_config=resources_config,

            region_name=region_name,
            vpc_name=vpc_name,
            vpc_cidr=vpc_cidr,

            public_subnet_name=public_subnet_name,
            public_subnet_cidr=public_subnet_cidr,
            public_subnet_availability_zone=public_subnet_availability_zone,
            igw_name=igw_name,
            non_main_rtb_name=non_main_rtb_name,

            private_subnet_name=private_subnet_name,
            private_subnet_cidr=private_subnet_cidr,
            private_subnet_availability_zone=private_subnet_availability_zone,
            main_rtb_name=main_rtb_name,

            security_group_name=security_group_name,
            security_group_rule_list=security_group_rule_list,
            default_security_group_name=default_security_group_name,

            create_new_key_pair=create_new_key_pair,
            key_pair_name=new_key_pair_name,
            path_to_save_new_pem_file=path_to_save_new_pem_file,
            # existing_rsa_private_key=old_key,

            public_subnet_ec2_instance_name=public_subnet_ec2_instance_name,
            private_subnet_ec2_instance_name=private_subnet_ec2_instance_name,
            ami_id=ec2_ubuntu_ami_id,
            instance_type=instance_type,

            prefix_str=prefix_str,

            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation=""
        )
        logger.info("ENDED: Build FQDN testing environment\n")


        ##### Step 03: Save/Store/Update config for teardown
        resources_config["timestamp_start"] = timestamp_start

        write_py_dict_to_config_file(
            logger=logger,
            py_dict=resources_config,
            path_to_file=path_to_teardown_config,
            log_indentation=""
        )


        logger.info("\n\nAFTER create_aws_fqdn_test_environment_by_wizard()")
        logger.info(json.dumps(resources_config, indent=4))


        ##### Step 04: Login Aviatrix Controller and Get CID
        logger.info("START: Login Aviatrix Controller and Get CID")
        aviatrix_controller_ip = config_avx["Aviatrix"]["UCC_Controller"]["public_ip"]
        api_endpoint = "https://" + aviatrix_controller_ip + "/v1/api"
        aviatrix_admin_password = config_avx["Aviatrix"]["UCC_Controller"]["admin_password"]

        response = login(
            logger=logger,
            url=api_endpoint,
            username="admin",
            password=aviatrix_admin_password
        )
        pydict = response.json()
        logger.info(json.dumps(pydict, indent=4))
        CID = None
        if(pydict["return"] == True):
            CID = pydict["CID"]

        logger.info("ENDED: Login Aviatrix Controller and Get CID\n")


        ##### Step 05: Create Aviatrix FQDN-Discovery Gateway
        logger.info("START: Create Aviatrix FQDN-Discovery Gateway")
        username = config_avx["Aviatrix"]["UCC_Controller"]["access_account_users"][0]["username"]
        vpc_id = resources_config["vpc_id"]
        public_subnet_cidr = resources_config["public_subnet_cidr"]
        gateway_name = "aviatrix-fqdn-gateway"

        response = create_gateway(
            logger=logger,
            url=api_endpoint,
            CID=CID,
            avx_cloud_account_name=username,
            cloud_type=1,
            vpc_region=region_name,
            vpc_id=vpc_id,
            subnet_name=public_subnet_cidr,
            gateway_size="t2.micro",
            gateway_name=gateway_name,
            allocate_new_eip="on",
            enable_nat="yes",
        )
        pydict = response.json()
        logger.info(json.dumps(pydict, indent=4))
        logger.info("ENDED: Create Aviatrix FQDN-Discovery Gateway\n")


        ##### Step 06: Save/Store/Update config for teardown
        resources_config["gateway_name"] = gateway_name

        write_py_dict_to_config_file(
            logger=logger,
            py_dict=resources_config,
            path_to_file=path_to_teardown_config,
            log_indentation=""
        )


        ##### Step 07: Start Aviatrix FQDN-Discovery
        logger.info("START: Start Aviatrix FQDN-Discovery")
        response = start_fqdn_discovery(
            logger=logger,
            url=api_endpoint,
            CID=CID,
            gateway_name=gateway_name
        )
        pydict = response.json()
        logger.info(json.dumps(pydict, indent=4))
        logger.info("ENDED: Start Aviatrix FQDN-Discovery\n")


        ##### Step 08: Connect to the VM in the public subnet
        logger.info("START: Connect to the VM in the public subnet")
        host_ip = resources_config["public_subnet_ec2_instance_public_ip"]
        username = "ubuntu"
        path_to_ssh_key = "./result/" + new_key_pair_name + ".pem"
        ssh_session = SSHSession(
            host_ip,
            username,
            path_to_ssh_key
        )
        logger.info("ENDED: Connect to the VM in the public subnet\n")


        ##### Step 09: Upload RSA Key .pem file to the VM in public subnet
        logger.info("START: Upload RSA Key .pem file to the VM in public subnet")
        path_to_save_in_remote = "/tmp/" + "key" + ".pem"
        ssh_session.upload_file(
            path_to_local_file=path_to_ssh_key,
            path_to_save_in_remote=path_to_save_in_remote
        )
        cmd_01 = "sudo chmod 600 " + path_to_save_in_remote
        ssh_session.exec_cmd(cmd_01)
        logger.info("ENDED: Upload RSA Key .pem file to the VM in public subnet\n")


        ##### Step 10: Invoke Linux commands to the VM in private subnet through the VM in public subnet
        logger.info("START: Invoke Linux commands to the VM in private subnet through the VM in public subnet")
        site_list = config_user["sites_to_visit"]

        for site in site_list:
            logger.info("    VM in private subnet is visiting [" + site + "]")
            cmd_02 = "sudo ssh -o 'StrictHostKeyChecking no' -i " + path_to_save_in_remote + " " + username + "@" + resources_config["private_subnet_ec2_instance_private_ip"] + " " + '"' + 'sudo curl ' + site + '"'
            try:
                cmd_result = ssh_session.exec_cmd(cmd_02)
            except UnicodeDecodeError as e:
                logger.warning("The website contains special character(s) that can't be interpreted.")
                tracekback_msg = traceback.format_exc()
                # logger.warning(tracekback_msg)
            finally:
                pass
        # END for (visiting sites)

        logger.info("ENDED: Invoke Linux commands to the VM in private subnet through the VM in public subnet\n")


        ##### Step 11: Verify Results Aviatrix from FQDN-Discery Gateway
        logger.info("START: Verify Results Aviatrix from FQDN-Discery Gateway")
        response = get_fqdn_discovery_result(
            logger=logger,
            url=api_endpoint,
            CID=CID,
            gateway_name=gateway_name
        )
        pydict = response.json()
        rtn_msg = pydict["results"]

        # Trim the rtn_msg string to the part that we need
        index = rtn_msg.find("\n\n")
        rtn_msg = rtn_msg[index+2:]  # index+2 to remove the 1st "\n\n"

        # Get all sites that visited (VM in the private subnet)
        result_site_list = rtn_msg.split(sep="\n")

        # Print Results
        logger.info("    Aviatrix FQDN Discovery has detected the following sites... ")
        for site in result_site_list:
            logger.info("    " + site)

        logger.info("ENDED: Verify Results Aviatrix from FQDN-Discery Gateway\n")

        # END
        logger.info("Successfully Completed FQDN Discovery Demonstration!!\n\n\n\n\n")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass
# EOF
