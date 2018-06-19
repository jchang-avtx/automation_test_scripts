
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
from lib.aviatrix.initial_setup import login
from lib.aviatrix.fqdn import stop_fqdn_discovery
from lib.aviatrix.gateway import delete_gateway_api
from lib.aws.ec2 import delete_aws_fqdn_test_environment_by_wizard



if __name__ == "__main__":
    try:
        ##### Script Configuration
        path_to_aws_config      = os.path.join(PATH_TO_PROJECT_ROOT_DIR, "config_global/aws_config.json")
        path_to_aviatrix_config = os.path.join(PATH_TO_PROJECT_ROOT_DIR, "config_global/aviatrix_config.json")
        path_to_teardown_config = "./config/config_for_teardown.json"


        ### Read configuration file
        with open(file=path_to_aws_config, mode="r") as input_file_stream:
            config_aws = json.load(fp=input_file_stream)

        ### Read configuration file
        with open(file=path_to_aviatrix_config, mode="r") as input_file_stream:
            config_avx = json.load(fp=input_file_stream)

        ##### Read configuration file into python-dict
        with open(file=path_to_teardown_config, mode="r") as file_input_stream:
            config_teardown = json.load(fp=file_input_stream)


        aws_access_key_id              = config_aws["AWS"]["Accounts"]["root"]["aws_access_key_id"]
        aws_secret_access_key          = config_aws["AWS"]["Accounts"]["root"]["aws_secret_access_key"]
        region_name                    = config_teardown["region_name"]

        public_subnet_ec2_instance_id  = config_teardown["public_subnet_ec2_instance_id"]
        private_subnet_ec2_instance_id = config_teardown["private_subnet_ec2_instance_id"]
        create_new_key_pair            = config_teardown["create_new_key_pair"]
        key_pair_name                  = config_teardown["key_pair_name"]
        security_group_id              = config_teardown["security_group_id"]

        main_rtb_association_id        = config_teardown["main_rtb_association_id"]
        non_main_rtb_association_id    = config_teardown["non_main_rtb_association_id"]
        non_main_rtb_id                = config_teardown["non_main_rtb_id"]
        igw_id                         = config_teardown["igw_id"]
        public_subnet_id               = config_teardown["public_subnet_id"]
        private_subnet_id              = config_teardown["private_subnet_id"]
        vpc_id                         = config_teardown["vpc_id"]

        timestamp_start  = config_teardown["timestamp_start"]
        path_to_log_file = "./result/" + timestamp_start + ".log"


        ##### Setup logger
        logger = set_logger(
            logger_name=__name__,
            logging_level=logging.INFO,
            log_file_enabled=True,
            path_to_log_file=path_to_log_file,
            log_file_mode="a"
        )


        ##### Login to Aviatrix Controller
        logger.info("START: Login to Aviatrix Controller")
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

        logger.info("ENDED: Login to Aviatrix Controller\n")


        ##### Stop Aviatrix FQDN Discovery
        logger.info("START: Stop Aviatrix FQDN Discovery")
        gateway_name = config_teardown["gateway_name"]
        response = stop_fqdn_discovery(
            logger=logger,
            url=api_endpoint,
            CID=CID,
            gateway_name=gateway_name
        )
        pydict = response.json()
        logger.info(json.dumps(pydict, indent=4))
        logger.info("ENDED: Stop Aviatrix FQDN Discovery\n")


        ##### Delete Aviatrix FQDN Discovery Gateway
        logger.info("START: Delete Aviatrix FQDN Discovery Gateway")
        response = delete_gateway_api(
            logger=logger,
            url=api_endpoint,
            CID=CID,
            cloud_type=1,
            gateway_name=gateway_name,
        )
        pydict = response.json()
        logger.info(json.dumps(pydict, indent=4))
        logger.info("START: Delete Aviatrix FQDN Discovery Gateway\n")


        ##### Delete AWS FQDN Test Environment
        logger.info("START: Delete AWS FQDN Test Environment")
        delete_aws_fqdn_test_environment_by_wizard(
            logger=logger,

            # resources_config=resources_config,
            region_name=region_name,

            public_subnet_ec2_instance_id=public_subnet_ec2_instance_id,
            private_subnet_ec2_instance_id=private_subnet_ec2_instance_id,
            create_new_key_pair=create_new_key_pair,
            key_pair_name=key_pair_name,
            security_group_id=security_group_id,

            main_rtb_association_id=main_rtb_association_id,
            non_main_rtb_association_id=non_main_rtb_association_id,
            non_main_rtb_id=non_main_rtb_id,
            igw_id=igw_id,
            private_subnet_id=private_subnet_id,
            public_subnet_id=public_subnet_id,
            vpc_id=vpc_id,

            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )
        logger.info("ENDED: Delete AWS FQDN Test Environment\n")

        logger.info("Successfully Restored Testing Environment!\n\n")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass
# EOF
