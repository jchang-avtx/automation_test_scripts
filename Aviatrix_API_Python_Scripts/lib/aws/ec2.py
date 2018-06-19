#!/usr/bin/python3
# -*- coding: UTF-8 -*-


import boto3
import datetime
import json
import logging
import os
import sys
import paramiko
import requests
import traceback
import time

from urllib3.exceptions import NewConnectionError
from urllib3.exceptions import MaxRetryError
from requests.exceptions import ConnectionError


PATH_TO_PROJECT_ROOT_DIR = "../"
sys.path.append(PATH_TO_PROJECT_ROOT_DIR)

from lib.util.apirequest import APIRequest
from lib.util.util import write_config_file, read_config_file

request_api = APIRequest()
logger = logging.getLogger(__name__)
CFG_EXT = '.cfg'
KEY_EXT = '.pem'


#######################################################################################################################
###############################################    Wizards     ########################################################
#######################################################################################################################


"""
* This function does the following...
    Step 01. Create VPC
    Step 02. Create Subnet (public subnet)
    Step 03. Create IGW
    Step 04. Attach IGW to VPC
    Step 05: Create Route-Table for VPC (which is creating the non-Main Route-Table)
    Step 06: Associate Non-Main Route table to Public Subnet
    Step xx: Create Default Route for Public Subnet's Route-Table
    Step xx: Create Subnet (private subnet)
    Step xx: Get Main-Route-Table ID
    Step xx: Associate Main Route table to Private Subnet
    Step xx: Create Security-Group
    Step xx: Authorize Security Group Ingress (SSH)
    Step xx: Authorize Security Group Ingress (HTTPS)
    Step xx: Authorize Security Group Ingress (HTTP)
    Step xx: Create key pair (pem file)
    Step xx: Create EC2 instance in Public Subenet
    Step xx: Create EC2 instance in Private Subenet
    

* The reason why we create the VM in the private subnet without assigning a public IP is because...
  If the VM in the private subnet has public IP, we can't SSH into the VM from the VM in public subnet because 
  VM (in private subnet) will try to use public IP to respond the SSH hand-shake.

* The return object is a python-dictionary, and it looks like the following...
    (This pydict is used for resources clean up purpose...)
{
    "region": "ca-central-1",
    "vpc_name": "@@@-vpc-2018-06-08_11-57-58",
    "vpc_cidr": "10.123.0.0/16",
    "public_subnet_name": "@@@-PubSub-2018-06-08_11-57-58",
    "public_subnet_cidr": "10.123.1.0/24",
    "public_subnet_availability_zone": "ca-central-1a",
    "igw_name": "@@@-igw-2018-06-08_11-57-58",
    "non_main_rtb_name": "@@@-non-main-rtb-2018-06-08_11-57-58",
    "private_subnet_name": "@@@-PriSub-2018-06-08_11-57-58",
    "private_subnet_cidr": "10.123.2.0/24",
    "private_subnet_availability_zone": "ca-central-1a",
    "main_rtb_name": "@@@-main-rtb-2018-06-08_11-57-58",
    "security_group_name": "@@@-sg-2018-06-08_11-57-58",
    "security_group_rule_list": [
        "SSH",
        "HTTPS",
        "HTTP",
        "All ICMP - IPv4"
    ],
    "public_subnet_ec2_instance_name": "@@@-ubuntu_vm_in_pub_sub-2018-06-08_11-57-58",
    "private_subnet_ec2_instance_name": "@@@-ubuntu_vm_in_pri_sub-2018-06-08_11-57-58",
    "ami_id": "ami-7e21a11a",
    "instance_type": "t2.micro",
    "create_new_key_pair": true,
    "key_pair_name": "@@@-keypair-2018-06-08_11-57-58",
    "prefix_str": "@@@",
    "vpc_id": "vpc-1e11ba76",
    "public_subnet_id": "subnet-9a2ad3e0",
    "igw_id": "igw-b8a28dd1",
    "default_security_group_id": "sg-91fa44fa",
    "non_main_rtb_id": "rtb-2c2ab144",
    "non_main_rtb_association_id": "rtbassoc-73c8cd1b",
    "private_subnet_id": "subnet-122bd268",
    "main_rtb_id": "rtb-e334af8b",
    "main_rtb_association_id": "rtbassoc-9bcecbf3",
    "security_group_id": "sg-fefd4395",
    "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAqTnkytl+mssOYW4DEUkVU0GUvKB4SCaWBkU7lNX4gtTMgYeW+bOdceAWz7wO\nzZgT7xXWk3uAAhck7qI7kW8U2H8ZrdhCLdgO2+ZfPoTutydZzbrBnqNmqjwaUA+ziGpHbcLw5wmJ\nhJkN94fmpl1ioEQ2yC26B0SGKoDXA4QIfSY8lROvpAsLhTf6s2p5dLeHcB5Pz0vbs0UqYbOB5Ddr\nhTXN0w9ghwB/VN6am8X8Cu+0DSC5zE4AZx+pyaBk3o28QdezpDFvsvlQFNeOCX/RTBUl/RWehVv8\nOlFgI/a8csshKStXya2vKMpg4pKHHB9q5G/ADSV2sn3ZSmeeZ5FOLQIDAQABAoIBAGxQNOOtH/69\ntx+fRXFb4L1gPW4aG8K6h83NpFwYNC6xO5Awk+6RC1YmwxMFYEgxbZja1nOhWYZ8/9OJnSzx91q2\nx13hDELBhokzQ4UFmrE6C53FSkZaecy+GW1jD1tiAwP7ASwvi4iGWk0z++pB3W2NG682rVoXfvRX\ncMe8S56lvxnNG51Op2V6QWRgBa3/kQyDNmjy7NOpcOhkiYpgSPgCE1JUlj6nXYq+a+Hu/iaPVztd\nXOXl8uQel+T+s+W2IUiVk/ndo3UhLMBsLk/QbVvvq4Bf82KHvolci00WpXKCMCQv30fu0syXtCXk\ntte1Q3wNmIvVSds7BxG7sOExhUECgYEA1bPaurIkoJFZqNuzbgXjbx3+P1HnV7gOqtf4WLRk3xZR\nqAfCv357/0LN2VVhPQsG6cp5GOrf4RZGCnU1bgLUs3LXnCuzlRvfcdyoiq/xgoeHfmLX506WSYKE\nCT8iJqkcIIUGsPkD6B78sTMJyB03ZrUy0M9gcoZXlqLouaNXq90CgYEAyrh0Hb2T81itzVgOq5q8\n1h8qAz7V4Qd7+HgBZNf0EeWFFhObhjpKGA0orkfMSC2a6vfDEl6HdohSplH0ZzRsOQxH46wc1V4W\n8gnFbYEfcl0wC45hW7pbYN7tdIUQO2JQchlAnMh10AZ/qvoHCSsUKGEOSs6i1evUzweKAmpQbpEC\ngYBm1D9InJWxSZ95+BWTuHOisSz47QFDnUY5gOh4Tn1HN2cdUnasTEGAJ3YDwOikRd0SvCGfEs2d\ncmlLePC3udb9biI/fGvSMPJIyKO08Epmw64363n2TENWpd3A0UcukSr+nuQEXh46IEb5QRTQ3PYe\njswf29mN4gTdcBBJ20ZBZQKBgFTTUAsty53U6oz1HtZhnki+q5bGETrjJdW3aWXoE0H113WAaOCG\nvYBI6U/bzTgalSti1yZ1lZtcubDMtEcHIY3RfLdgyoPhphpLSmhi0mTJZ5Q+VLDMTvY+8f+CumMO\n5XiI5od0Pg/42C0UCCOm+f1Xd2KICo0W7GpgzjfqgpNxAoGAUcPiVPuZZLuZrjEjUa49rFkp/8sf\nF5x0jW4Dl+SMdFLXjbHRLykm452+esQQjNs0gQ4hN0bF0HEOtKtHKUUCjBgKR6JeeZ+vJ19vky7v\n9R/4uTs4mg153ncMlYg73yaXqewZfo4oRc5e9EuT0n+0JtEZXsCuXQT5v3YJolEG0Y0=\n-----END RSA PRIVATE KEY-----",
    "public_subnet_ec2_instance_id": "i-037ccbb0c924dbdf1",
    "public_subnet_ec2_instance_private_ip": "10.123.1.66",
    "public_subnet_ec2_instance_public_ip": "35.183.45.52",
    "private_subnet_ec2_instance_id": "i-013053b999e05b553",
    "private_subnet_ec2_instance_private_ip": "10.123.2.7"
}
"""
def create_aws_fqdn_test_environment_by_wizard(
                logger=None,
                resources_config=None,  # json

                region_name="us-west-2",
                vpc_name="auto-vpc",
                vpc_cidr="10.99.0.0/16",

                public_subnet_name="auto-public-subnet",
                public_subnet_cidr="10.99.1.0/24",
                public_subnet_availability_zone="us-west-2a",
                igw_name="auto-igw",
                non_main_rtb_name="auto-non-main-rtb",

                private_subnet_name="auto-private-subnet",
                private_subnet_cidr="10.99.2.0/24",
                private_subnet_availability_zone="us-west-2a",
                main_rtb_name="auto-main-rtb",

                security_group_name="",
                security_group_rule_list=list(["SSH", "HTTPS", "HTTP", "All ICMP - IPv4"]),
                default_security_group_name="",

                create_new_key_pair=True,
                key_pair_name="auto-keypair",
                path_to_save_new_pem_file=None,
                existing_rsa_private_key=None,  # required only when create_new_key_pair == True

                public_subnet_ec2_instance_name="auto-vm-in-PubSub",
                private_subnet_ec2_instance_name="auto-vm-in-PriSub",
                ami_id="ami-db710fa3",
                instance_type="t2.micro",

                prefix_str="auto",

                aws_access_key_id=None,
                aws_secret_access_key=None,
                log_indentation=""
                ):
    try:
        logger.info(log_indentation + "START: create_aws_fqdn_test_environment()")

        if resources_config is None:
            resources_config = dict()

            resources_config["region_name"] = region_name
            resources_config["vpc_name"] = vpc_name
            resources_config["vpc_cidr"] = vpc_cidr

            resources_config["public_subnet_name"] = public_subnet_name
            resources_config["public_subnet_cidr"] = public_subnet_cidr
            resources_config["public_subnet_availability_zone"] = public_subnet_availability_zone

            resources_config["igw_name"] = igw_name
            resources_config["non_main_rtb_name"] = non_main_rtb_name

            resources_config["private_subnet_name"] = private_subnet_name
            resources_config["private_subnet_cidr"] = private_subnet_cidr
            resources_config["private_subnet_availability_zone"] = private_subnet_availability_zone
            resources_config["main_rtb_name"] = main_rtb_name

            resources_config["security_group_name"] = security_group_name
            resources_config["security_group_rule_list"] = security_group_rule_list

            resources_config["public_subnet_ec2_instance_name"] = public_subnet_ec2_instance_name
            resources_config["private_subnet_ec2_instance_name"] = private_subnet_ec2_instance_name
            resources_config["ami_id"] = ami_id
            resources_config["instance_type"] = instance_type

            if create_new_key_pair is True:
                resources_config["create_new_key_pair"]      = create_new_key_pair
                resources_config["key_pair_name"]            = key_pair_name
            else:
                resources_config["create_new_key_pair"]      = create_new_key_pair
                resources_config["key_pair_name"]            = key_pair_name
                resources_config["private_key"]              = existing_rsa_private_key

            resources_config["prefix_str"] = prefix_str

        else:
            region_name = resources_config["region_name"]

            vpc_name = resources_config["vpc_name"]
            vpc_cidr = resources_config["vpc_cidr"]

            public_subnet_name = resources_config["public_subnet_name"]
            public_subnet_cidr = resources_config["public_subnet_cidr"]
            public_subnet_availability_zone = resources_config["public_subnet_availability_zone"]

            igw_name = resources_config["igw_name"]
            non_main_rtb_name = resources_config["non_main_rtb_name"]

            private_subnet_name = resources_config["private_subnet_name"]
            private_subnet_cidr = resources_config["private_subnet_cidr"]
            private_subnet_availability_zone = resources_config["private_subnet_availability_zone"]
            main_rtb_name = resources_config["main_rtb_name"]

            security_group_name = resources_config["security_group_name"]
            security_group_rule_list = resources_config["security_group_rule_list"]

            public_subnet_ec2_instance_name = resources_config["public_subnet_ec2_instance_name"]
            private_subnet_ec2_instance_name = resources_config["private_subnet_ec2_instance_name"]
            ami_id = resources_config["ami_id"]
            instance_type = resources_config["instance_type"]

            if create_new_key_pair is True:
                create_new_key_pair = resources_config["create_new_key_pair"]
                key_pair_name = resources_config["key_pair_name"]
            else:
                create_new_key_pair = resources_config["create_new_key_pair"]
                key_pair_name = resources_config["key_pair_name"]
                private_key = resources_config["private_key"]

            prefix_str = resources_config["prefix_str"]

            prefix_str = resources_config["prefix_str"]
        # END if-else


        ec2_resource = boto3.resource(
            service_name='ec2',
            region_name=region_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key
        )


        ### Step xx: Create VPC
        resources_config["vpc_id"] = create_vpc(
            logger=logger,
            region=region_name,
            cidr=vpc_cidr,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ### Step xx: Create Name-Tag for VPC
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["vpc_id"],
            name=vpc_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ### Step xx: Create Public Subnet (The "Main" Route-Table will also be created automatically)
        resources_config["public_subnet_id"] = create_subnet(
            logger=logger,
            region=region_name,
            vpc_id=resources_config["vpc_id"],
            cidr=public_subnet_cidr,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ##### Step xx: Create Name-Tag for Public Subnet
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["public_subnet_id"],
            name=public_subnet_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Create IGW
        resources_config["igw_id"] = create_igw(
            logger=logger,
            region=region_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ##### Step xx: Create Name-Tag for IGW
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["igw_id"],
            name=igw_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ##### Step xx: Attach IGW to VPC
        attach_igw_to_vpc(
            logger=logger,
            region=region_name,
            igw_id=resources_config["igw_id"],
            vpc_id=resources_config["vpc_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Create Name-Tag for the default Security-Group of the VPC
        default_security_group_id = get_default_security_group_id_from_vpc(
            logger=logger,
            region_name=region_name,
            vpc_id=resources_config["vpc_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        create_name_tag(
            logger=logger,
            region=region_name,
            resource=default_security_group_id,
            name=default_security_group_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )
        resources_config["default_security_group_id"] = default_security_group_id


        ##### Step xx: Create (non-main) Route-Table for VPC
        resources_config["non_main_rtb_id"] = create_route_table(
            logger=logger,
            region=region_name,
            vpc_id=resources_config["vpc_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ##### Step xx: Create Name-Tag for (non-main) route table
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["non_main_rtb_id"],
            name=non_main_rtb_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Associate Non-Main Route-Table to Public Subnet
        resources_config["non_main_rtb_association_id"] = associate_route_table_to_subnet(
            logger=logger,
            region=region_name,
            route_table_id=resources_config["non_main_rtb_id"],
            subnet_id=resources_config["public_subnet_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Create Default Route to Public-Subnet's Route-Table
        create_route(
            logger=logger,
            region=region_name,
            route_table_id=resources_config["non_main_rtb_id"],
            destnation_cidr="0.0.0.0/0",
            igw_id=resources_config["igw_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ### Step xx: Create Private Subnet
        resources_config["private_subnet_id"] = create_subnet(
            logger=logger,
            region=region_name,
            vpc_id=resources_config["vpc_id"],
            cidr=private_subnet_cidr,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ##### Step xx: Create Name-Tag for Private Subnet
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["private_subnet_id"],
            name=private_subnet_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Get Main-Route-Table ID
        resources_config["main_rtb_id"] = get_main_route_table_id_by_vpc_id(
            logger=logger,
            region=region_name,
            vpc_id=resources_config["vpc_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        ##### Step xx: Create Name-Tag for Main Route-Table
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["main_rtb_id"],
            name=main_rtb_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Associate Main Route-Table to Private Subnet
        resources_config["main_rtb_association_id"] = associate_route_table_to_subnet(
            logger=logger,
            region=region_name,
            route_table_id=resources_config["main_rtb_id"],
            subnet_id=resources_config["private_subnet_id"],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Step xx: Create Security-Group
        security_group_id = create_security_group(
            logger=logger,
            region=region_name,
            vpc_id=resources_config["vpc_id"],
            security_group_name=security_group_name,
            description=security_group_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )
        resources_config["security_group_id"] = security_group_id


        ##### Step xx: Create Name-Tag for Security Group
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=resources_config["security_group_id"],
            name=security_group_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key
        )


        ##### Step xx: Authorize Security Group Ingress (SSH)
        if "SSH" in security_group_rule_list:
            authorize_security_group_ingress(
                logger=logger,
                region=region_name,
                security_group_id=resources_config["security_group_id"],
                security_group_name=security_group_name,
                ip_protocal="tcp",
                port_range_from=22,
                port_range_to=22,
                source_ip_cidr="0.0.0.0/0",
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key
            )
        #END IF


        ##### Step xx: Authorize Security Group Ingress (HTTPS)
        if "HTTPS" in security_group_rule_list:
            authorize_security_group_ingress(
                logger=logger,
                region=region_name,
                security_group_id=resources_config["security_group_id"],
                security_group_name=security_group_name,
                ip_protocal="tcp",
                port_range_from=443,
                port_range_to=443,
                source_ip_cidr="0.0.0.0/0",
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key
            )
        # END IF


        ##### Step xx: Authorize Security Group Ingress (HTTP)
        if "HTTPS" in security_group_rule_list:
            authorize_security_group_ingress(
                logger=logger,
                region=region_name,
                security_group_id=resources_config["security_group_id"],
                security_group_name=security_group_name,
                ip_protocal="tcp",
                port_range_from=80,
                port_range_to=80,
                source_ip_cidr="0.0.0.0/0",
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key
            )
        # END IF


        ##### Step xx: Authorize Security Group Ingress (ICMP)
        if "All ICMP - IPv4" in security_group_rule_list:
            authorize_security_group_ingress(
                logger=logger,
                region=region_name,
                security_group_id=resources_config["security_group_id"],
                security_group_name=security_group_name,
                ip_protocal="icmp",
                port_range_from=-1,
                port_range_to=-1,
                source_ip_cidr="0.0.0.0/0",
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key
            )
        # END IF


        ##### Step xx: Create key pair (pem file) IF specified
        if create_new_key_pair == True:
            private_key = create_key_pair(
                logger=logger,
                region=region_name,
                key_pair_name=key_pair_name,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
            resources_config["key_pair_name"] = key_pair_name
            resources_config["private_key"]   = private_key

            ### Create a text (.pem) file in local for the new key pair
            with open(file=path_to_save_new_pem_file, mode="w") as output_file_stream:
                output_file_stream.write(private_key)
            # END creating local pem file for new key
        #END create new key pair


        ##### Create EC2 Instance in Public Subnet
        instance_id, private_ip = run_instance(
            logger=logger,
            region=region_name,
            ami_id=ami_id,
            subnet_id=resources_config["public_subnet_id"],
            instance_type=instance_type,
            vm_name=public_subnet_ec2_instance_name,
            key_pair_name=key_pair_name,
            security_group_id=security_group_id,
            auto_assign_public_ip=True,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )
        resources_config["public_subnet_ec2_instance_id"] = instance_id
        resources_config["public_subnet_ec2_instance_private_ip"] = private_ip


        ##### Step xx: Get the default public ip of the ec2 instance in the public subnet
        ec2_instance = ec2_resource.Instance(instance_id)
        public_subnet_ec2_instance_public_ip = ec2_instance.public_ip_address
        resources_config["public_subnet_ec2_instance_public_ip"] = public_subnet_ec2_instance_public_ip


        ##### Step xx: Create Name-Tag for EC2 Instance in Public Subnet
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=instance_id,
            name=public_subnet_ec2_instance_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )


        ##### Create EC2 Instance in Private Subnet
        instance_id, private_ip = run_instance(
            logger=logger,
            region=region_name,
            ami_id=ami_id,
            subnet_id=resources_config["private_subnet_id"],
            instance_type=instance_type,
            vm_name=private_subnet_ec2_instance_name,
            key_pair_name=key_pair_name,
            security_group_id=security_group_id,
            auto_assign_public_ip=False,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )
        resources_config["private_subnet_ec2_instance_id"] = instance_id
        resources_config["private_subnet_ec2_instance_private_ip"] = private_ip



        ##### Step xx: Create Name-Tag for EC2 Instance in Private Subnet
        create_name_tag(
            logger=logger,
            region=region_name,
            resource=instance_id,
            name=private_subnet_ec2_instance_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )

        logger.info(log_indentation + "Succeeded!")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: create_aws_fqdn_test_environment_by_wizard()")
        return resources_config  # Regardless having error in the middle of the whole function or not, we should return whatever we have in "resources_config"
# END create_aws_fqdn_test_environment_by_wizard()


"""
This function does the following...
    Step xx. Delete Public Subnet VM
    Step xx. Delete Private Subnet VM
    Step xx. Delete Key-Pair
    Step xx. Delete Security-Group
    Step xx. Disassociate Main Route-Table from Private Subnet
    Step xx. Disassociate Route-Table from Public Subnet
    Step xx. Delete non-Main Route-Table
    Step xx. Detach IGW from VPC
    Step xx. Delete IGW
    Step xx. Delete Private Subnet
    Step xx. Delete Public Subnet
    Step xx. Delete VPC

NOTE: 
    If you decide to pass "config" (python-dict) without explicitly specifying other resource-IDs, 
    then "config, the "resources_config" (python-dict) MUST contain the following...

{
    "region_name": "ca-central-1",
    
    "public_subnet_ec2_instance_id": "i-06d2cc76579a22f50",
    "private_subnet_ec2_instance_id": "i-05059188b739e2b88",
    
    "create_new_key_pair": true,
    "key_pair_name": "ccc-keypair-2018-05-31_16-51-49",
    
    "security_group_id": "sg-e1df758a",
    
    "igw_id": "igw-b9664bd0",
    "non_main_rtb_id": "rtb-e8d54980",
    "non_main_rtb_association_id": "rtbassoc-9ec1fcf6",
    "main_rtb_id": "rtb-52d64a3a",
    "main_rtb_association_id": "rtbassoc-ecc6fb84",
    
    "public_subnet_id": "subnet-c81de0b2",
    "private_subnet_id": "subnet-e31fe299",
    "vpc_id": "vpc-3e5ef256",
}

"""
def delete_aws_fqdn_test_environment_by_wizard(
                logger=None,

                resources_config=None,
                region_name="us-west-2",

                public_subnet_ec2_instance_id="i-xxxxxxxxxx",
                private_subnet_ec2_instance_id="i-xxxxxxxxxx",
                create_new_key_pair=True,
                key_pair_name="auto-keypair",
                security_group_id="sg-xxxxxxxxxx",

                main_rtb_association_id=None,
                non_main_rtb_association_id=None,
                non_main_rtb_id=None,
                igw_id="igw-xxxxxxxxxx",
                public_subnet_id="subnet-xxxxxxxxxx",
                private_subnet_id="subnet-xxxxxxxxxx",
                vpc_id="vpc-xxxxxxxxxx",

                aws_access_key_id=None,
                aws_secret_access_key=None,
                log_indentation=""
                ):
    try:
        logger.info(json.dumps(resources_config, indent=4))  ####################################################################################
        logger.info(log_indentation + "START: delete_aws_fqdn_test_environment_by_wizard()")


        # IF user passes "resources_config" (python-dict), then get the resources_configuration data from "resources_config"
        if resources_config is None:
            resources_config                                   = dict()
            resources_config["region_name"]                    = region_name

            resources_config["public_subnet_ec2_instance_id"]  = public_subnet_ec2_instance_id
            resources_config["private_subnet_ec2_instance_id"] = private_subnet_ec2_instance_id
            resources_config["create_new_key_pair"]            = create_new_key_pair
            resources_config["key_pair_name"]                  = key_pair_name
            resources_config["security_group_id"]              = security_group_id

            resources_config["main_rtb_association_id"]        = main_rtb_association_id
            resources_config["non_main_rtb_association_id"]    = non_main_rtb_association_id
            resources_config["non_main_rtb_id"]                = non_main_rtb_id
            resources_config["igw_id"]                         = igw_id
            resources_config["public_subnet_id"]               = public_subnet_id
            resources_config["private_subnet_id"]              = private_subnet_id
            resources_config["vpc_id"]                         = vpc_id
        else:
            region_name                    = resources_config["region_name"]

            public_subnet_ec2_instance_id  = resources_config["public_subnet_ec2_instance_id"]
            private_subnet_ec2_instance_id = resources_config["private_subnet_ec2_instance_id"]
            create_new_key_pair            = resources_config["create_new_key_pair"]
            key_pair_name                  = resources_config["key_pair_name"]
            security_group_id              = resources_config["security_group_id"]

            main_rtb_association_id        = resources_config["main_rtb_association_id"]
            non_main_rtb_association_id    = resources_config["non_main_rtb_association_id"]
            non_main_rtb_id                = resources_config["non_main_rtb_id"]
            igw_id                         = resources_config["igw_id"]
            public_subnet_id               = resources_config["public_subnet_id"]
            private_subnet_id              = resources_config["private_subnet_id"]
            vpc_id                         = resources_config["vpc_id"]
        # END if-else


        ##### Delete EC2 Instance in Public Subnet
        terminate_instances(
            logger=logger,
            region=region_name,
            instance_id_list=[public_subnet_ec2_instance_id],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key
        )


        ##### Delete EC2 Instance in Private Subnet
        terminate_instances(
            logger=logger,
            region=region_name,
            instance_id_list=[private_subnet_ec2_instance_id],
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key
        )


        time.sleep(100)  # There was one time tried 60 sec but failed


        ##### Delete Key-Pair
        if create_new_key_pair == True:
            delete_key_pair(
                logger=logger,
                region=region_name,
                key_pair_name=key_pair_name,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key
            )
        #END delete key-pair


        ##### Delete Security-Group
        try:
            ##### Delete Security-Group
            delete_security_group(
                logger=logger,
                region=region_name,
                security_group_id=security_group_id,
                # security_group_name=resources_config["security_group_name"],
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(msg=tracekback_msg)



        ##### Disassociate Main Route-Table from Private Subnet
        try:
            disassociate_route_table(
                logger=logger,
                region=region_name,
                route_table_association_id=main_rtb_association_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(msg=tracekback_msg)


        ##### Disassociate Non-Main Route-Table from Public Subnet
        try:
            disassociate_route_table(
                logger=logger,
                region=region_name,
                route_table_association_id=non_main_rtb_association_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(msg=tracekback_msg)


        ##### Delete the Non-Main Route-Table
        try:
            delete_route_table(
                logger=logger,
                region=region_name,
                route_table_id=non_main_rtb_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(msg=tracekback_msg)


        ##### Detach IGW from VPC
        try:
            detach_igw_from_vpc(
                logger=logger,
                region=region_name,
                igw_id=igw_id,
                vpc_id=vpc_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(msg=tracekback_msg)


        #### Delete IGW
        try:
            delete_igw(
                logger=logger,
                region=region_name,
                igw_id=igw_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(msg=tracekback_msg)


        ##### Delete Private Subnet
        try:
            delete_subnet(
                logger=logger,
                region=region_name,
                subnet_id=private_subnet_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)


        ##### Delete Public Subnet
        try:
            delete_subnet(
                logger=logger,
                region=region_name,
                subnet_id=public_subnet_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)


        ##### Delete VPC
        try:
            delete_vpc(
                logger=logger,
                region=region_name,
                vpc_id=vpc_id,
                aws_access_key_id=aws_access_key_id,
                aws_secret_access_key=aws_secret_access_key,
                log_indentation="    "
            )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)


        logger.info(log_indentation + "Successfully completed delete_aws_fqdn_test_environment_by_wizard() task!")
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)
    finally:
        logger.info(log_indentation + "ENDED: delete_aws_fqdn_test_environment_by_wizard()")
# END delete_aws_fqdn_test_environment_by_wizard()


#######################################################################################################################
###########################################    Route-Table     ########################################################
#######################################################################################################################
def get_main_route_table_id_by_vpc_id(logger=None,
                                      region="",
                                      vpc_id="",
                                      aws_access_key_id="",
                                      aws_secret_access_key="",
                                      log_indentation=""):
    logger.info(log_indentation + "START: Get main route table ID by VPC ID: " + vpc_id)

    ### Get AWS-EC2-Client connection object
    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    filters = [
        {
            'Name': 'vpc-id',
            'Values': [vpc_id]
        }
    ]

    try:
        ### Call AWS API
        response = ec2_client.describe_route_tables(
            Filters=filters,
            DryRun=False,
            # RouteTableIds=[
            #     'string',
            # ]
        )

        # logger.info(log_indentation + "    Succeed")
        # logger.info(log_indentation + "    " + str(response))
        main_route_table_id = ""
        found = False
        route_tables = response["RouteTables"]
        for route_table in route_tables:
            # print(json.dumps(route_table, indent=4))
            if route_table["Associations"][0]["Main"] is True:
                logger.info(log_indentation + "Found main_route_table_id")
                main_route_table_id = route_table["Associations"][0]["RouteTableId"]
                logger.info(log_indentation + "main_route_table_id: " + main_route_table_id)
                found = True
        # EDN for

        if found is False:
            logger.error(log_indentation + "Did NOT find main_route_table_id")

        return main_route_table_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "END: Get main route table ID by VPC ID: " + vpc_id + "\n")
# END get_main_route_table_id_by_vpc_id()


#######################################################################################################################
#################################################    Tag     ##########################################################
#######################################################################################################################
def create_name_tag(logger=None,
                    region="",
                    resource="",
                    name="",
                    aws_access_key_id="",
                    aws_secret_access_key="",
                    max_retry=5,
                    log_indentation=""
                    ):
    # logger.info(log_indentation + "START: Create Name Tag")

    resources = list()
    resources.append(resource)

    tags = [
        {
            "Key": "Name",
            "Value": name
        }
    ]

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        for i in range(max_retry):
            try:
                ##### Step 01: Create Name Tag
                response = ec2_client.create_tags(
                    Resources=resources,
                    Tags=tags,
                    DryRun=False
                )

            except Exception as e:
                tracekback_msg = traceback.format_exc()
                logger.error(tracekback_msg)
        # END for

        # logger.info(log_indentation + "    Succeed")
        # logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        # logger.info(log_indentation + "ENDED: Create Name Tag\n")
        pass


#######################################################################################################################
#################################################    VPC     ##########################################################
#######################################################################################################################
def create_vpc(logger=None, region="", cidr="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Create VPC")
    instance_tenancy = "default"  # Valid Value: "default" || "dedicated" || "host"

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    ec2_resource = boto3.resource(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create VPC
        response = ec2_client.create_vpc(
            CidrBlock=cidr,
            AmazonProvidedIpv6CidrBlock=False,
            DryRun=False,
            InstanceTenancy=instance_tenancy
        )
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get VPC ID
        logger.info(log_indentation + "    Successfully created a VPC.")
        vpc_id = response["Vpc"]["VpcId"]
        logger.info(log_indentation + "    VPC ID: " + vpc_id)

        ##### Step 03: Wait until VPC is available
        logger.info(log_indentation + "    Wait until VPC is available")
        vpc = None
        # The for loop is to Wait for the newly created VPC to be ready/visible to "vpc = ec2_resource.Vpc(vpc_id)", so the "vpc" value is NOT None
        for i in range(5):
            vpc = ec2_resource.Vpc(vpc_id)  # Get VPC object
            if vpc is not None:
                break
        # END for

        vpc.wait_until_exists()
        vpc.wait_until_available()

        ##### Step 04: Modify VPC Attributes to set "DNS hostnames" to "yes"
        logger.info(log_indentation + "    Modify VPC Attributes and set \"DNS hostnames\" to \"yes\"")

        response = ec2_client.modify_vpc_attribute(
            EnableDnsHostnames={
                'Value': True
            },
            VpcId=vpc_id
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return vpc_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create VPC\n")


def delete_vpc(logger=None, region="", vpc_id="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Delete VPC")
    region = region

    try:
        ec2_client = boto3.client(
            service_name='ec2',
            region_name=region,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key
        )

        response = ec2_client.delete_vpc(
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete VPC\n")


#######################################################################################################################
#################################################    Subnet     #######################################################
#######################################################################################################################
def create_subnet(logger=None,
                  region="",
                  vpc_id="",
                  availability_zone="",
                  cidr="",
                  aws_access_key_id="",
                  aws_secret_access_key="",
                  log_indentation=""
                  ):
    logger.info(log_indentation + "START: Create Subnet")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create Subnet
        response = ec2_client.create_subnet(
            AvailabilityZone=availability_zone,
            CidrBlock=cidr,
            # Ipv6CidrBlock='string',
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Subnet ID
        logger.info(log_indentation + "    Successfully created a Subnet.")
        subnet_id = response["Subnet"]["SubnetId"]
        logger.info(log_indentation + "    Subnet ID: " + subnet_id)

        ##### Step 03: Wait until Subnet is available
        # logger.info("    Wait until Subnet is available\n")
        # subnet = ec2_resource.Subnet(subnet_id)  # Get VPC object
        # subnet.wait_until_available()

        return subnet_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Subnet\n")


def delete_subnet(logger=None, 
                  region="", 
                  subnet_id="", 
                  aws_access_key_id="", 
                  aws_secret_access_key="", 
                  log_indentation=""
                  ):
    logger.info(log_indentation + "START: Delete Subnet")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        response = ec2_client.delete_subnet(
            SubnetId=subnet_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Subnet\n")


#######################################################################################################################
###################################################    IGW     ########################################################
#######################################################################################################################
def create_igw(logger=None, region="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Create IGW")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create IGW
        response = ec2_client.create_internet_gateway(
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get IGW ID
        igw_id = response["InternetGateway"]["InternetGatewayId"]
        logger.info(log_indentation + "    IGW ID: " + igw_id)

        return igw_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create IGW\n")


def delete_igw(logger=None, region="", igw_id="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Delete IGW")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete IGW
        response = ec2_client.delete_internet_gateway(
            InternetGatewayId=igw_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return igw_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete IGW\n")


def attach_igw_to_vpc(logger=None, 
                      region="", 
                      igw_id="", 
                      vpc_id="", 
                      aws_access_key_id="", 
                      aws_secret_access_key="",
                      log_indentation=""
                      ):
    logger.info(log_indentation + "START: Attach IGW " + igw_id + " to VPC " + vpc_id)

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Attach IGW
        response = ec2_client.attach_internet_gateway(
            InternetGatewayId=igw_id,
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Attach IGW " + igw_id + " to VPC " + vpc_id)


def detach_igw_from_vpc(logger=None, 
                        region="", 
                        igw_id="", 
                        vpc_id="", 
                        aws_access_key_id="", 
                        aws_secret_access_key="",
                        log_indentation=""
                        ):
    logger.info(log_indentation + "START: Detach IGW from VPC")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        # Step 01: Detach IGW from VPC
        response = ec2_client.detach_internet_gateway(
            InternetGatewayId=igw_id,
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Detach IGW\n")


#######################################################################################################################
###############################################    Route Table     ####################################################
#######################################################################################################################
def create_route_table(logger=None, 
                       region="", 
                       vpc_id="", 
                       aws_access_key_id="", 
                       aws_secret_access_key="",
                       log_indentation=""
                       ):
    logger.info(log_indentation + "START: Create Route-Table")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create Route-Table
        response = ec2_client.create_route_table(
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get route table ID
        route_table_id = response["RouteTable"]["RouteTableId"]
        logger.info(log_indentation + "    Route-Table ID: " + route_table_id)

        return route_table_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Route-Table\n")


def delete_route_table(logger=None, 
                       region="", 
                       route_table_id="", 
                       aws_access_key_id="", 
                       aws_secret_access_key="",
                       log_indentation=""
                       ):
    logger.info(log_indentation + "START: Delete route table: " + route_table_id)

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete route table
        response = ec2_client.delete_route_table(
            RouteTableId=route_table_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete route table: " + route_table_id + "\n")


def associate_route_table_to_subnet(logger=None,
                                    region="",
                                    route_table_id="",
                                    subnet_id="",
                                    aws_access_key_id="",
                                    aws_secret_access_key="",
                                    log_indentation=""
                                    ):
    logger.info(log_indentation + "START: Associate route table to subnet")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Associate route table to subnet
        response = ec2_client.associate_route_table(
            RouteTableId=route_table_id,
            SubnetId=subnet_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        route_table_association_id = response["AssociationId"]
        logger.info(log_indentation + "AssociationId: " + route_table_association_id)
        return route_table_association_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Associate route table to subnet\n")


def disassociate_route_table(logger=None,
                             region="",
                             route_table_association_id="",
                             aws_access_key_id="",
                             aws_secret_access_key="",
                             log_indentation=""
                             ):
    logger.info(log_indentation + "START: Disassociate route table from subnet")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01:     logger.info("START: Disassociate route table from subnet")

        response = ec2_client.disassociate_route_table(
            AssociationId=route_table_association_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Disassociate route table from subnet\n")


def create_route(logger=None,
                 region="",
                 route_table_id="",
                 destnation_cidr="",
                 igw_id="",
                 network_interface_id="",
                 aws_access_key_id="",
                 aws_secret_access_key="",
                 log_indentation=""
                 ):
    logger.info(log_indentation + "START: Create route to route-table: " + route_table_id)

    ec2_resource = boto3.resource(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )
    route_table = ec2_resource.RouteTable(route_table_id)

    try:
        ##### Step 01: Create route to route-table
        route = route_table.create_route(
            DestinationCidrBlock=destnation_cidr,
            # DestinationIpv6CidrBlock='string'
            # EgressOnlyInternetGatewayId='sring',
            GatewayId=igw_id,
            # InstanceId='string',
            # NatGatewayId='string',
            # NetworkInterfaceId='string',
            # VpcPeeringConnectionId='string',
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create route to route-table: " + route_table_id + "\n")


def delete_route(logger=None,
                 region="",
                 route_table_id="",
                 destnation_cidr="",
                 aws_access_key_id="",
                 aws_secret_access_key="",
                 log_indentation=""
                 ):
    logger.info(log_indentation + "START: Delete Route")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete Route
        response = ec2_client.delete_route(
            RouteTableId=route_table_id,
            DestinationCidrBlock=destnation_cidr,
            # DestinationIpv6CidrBlock='string',
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Route\n")


def get_route_table_id_from_subnet(logger=None,
                                   region="",
                                   subnet_id="",
                                   aws_access_key_id="",
                                   aws_secret_access_key="",
                                   log_indentation=""
                                   ):
    logger.info(log_indentation + "START: Get route table ID from subnet: " + subnet_id)

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Get route table ID from subnet
        response = ec2_client.describe_route_tables(
            Filters=[
                {
                    'Name': 'association.subnet-id',
                    'Values': [
                        subnet_id
                    ]
                }
            ]
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Get route table ID from response
        route_table_id = response['RouteTables'][0]['Associations'][0]['RouteTableId']
        logger.info(log_indentation + "    Route table ID: " + route_table_id)

        return route_table_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Get route table ID from subnet: " + subnet_id + "\n")


#######################################################################################################################
##########################################    Security Group     ######################################################
#######################################################################################################################

"""
Notes:
    * The parameter "description" can NOT take special characters such as dash '-' and underscore '_'
"""
def create_security_group(logger=None,
                          region="",
                          vpc_id="",
                          security_group_name="",
                          description="",
                          aws_access_key_id="",
                          aws_secret_access_key="",
                          log_indentation=""
                          ):
    logger.info(log_indentation + "START: Create Security-Group for VPC: " + vpc_id)

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create Security-Group
        response = ec2_client.create_security_group(
            VpcId=vpc_id,
            GroupName=security_group_name,
            Description=description,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Security-Group ID
        security_group_id = response["GroupId"]
        logger.info(log_indentation + "    Security-Group ID: " + security_group_id)

        return security_group_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Security-Group for VPC: " + vpc_id + "\n")


def delete_security_group(logger=None,
                          region="",
                          security_group_id="",
                          security_group_name="",
                          aws_access_key_id="",
                          aws_secret_access_key="",
                          log_indentation=""
                          ):
    logger.info(log_indentation + "START: Delete Security-Group")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete Security-Group
        response = ec2_client.delete_security_group(
            GroupId=security_group_id,
            # GroupName=security_group_name,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Security-Group\n")


"""
Create a inbound rule for a security group
"""
def authorize_security_group_ingress(logger=None,
                                     region="",
                                     security_group_id="",
                                     security_group_name="",
                                     ip_protocal="",
                                     port_range_from="",
                                     port_range_to="",
                                     source_ip_cidr="",
                                     aws_access_key_id="",
                                     aws_secret_access_key="",
                                     log_indentation=""
                                     ):
    logger.info(log_indentation + "START: Create a rule for Security Group: " + security_group_id)

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        # Step 01: Create a rule for Security Group
        response = ec2_client.authorize_security_group_ingress(
            GroupId=security_group_id,
            # GroupName=security_group_name,  # either specifying sg-id or sg-name
            IpProtocol=ip_protocal,
            FromPort=port_range_from,
            ToPort=port_range_to,
            CidrIp=source_ip_cidr,
            # SourceSecurityGroupName='string',
            # SourceSecurityGroupOwnerId='string',

            # IpPermissions=[
            #     {
            #         'FromPort': 123,
            #         'IpProtocol': 'string',
            #         'IpRanges': [
            #             {
            #                 'CidrIp': 'string',
            #                 'Description': 'string'
            #             },
            #         ],
            #         'Ipv6Ranges': [
            #             {
            #                 'CidrIpv6': 'string',
            #                 'Description': 'string'
            #             },
            #         ],
            #         'PrefixListIds': [
            #             {
            #                 'Description': 'string',
            #                 'PrefixListId': 'string'
            #             },
            #         ],
            #         'ToPort': 123,
            #         'UserIdGroupPairs': [
            #             {
            #                 'Description': 'string',
            #                 'GroupId': 'string',
            #                 'GroupName': 'string',
            #                 'PeeringStatus': 'string',
            #                 'UserId': 'string',
            #                 'VpcId': 'string',
            #                 'VpcPeeringConnectionId': 'string'
            #             },
            #         ]
            #     },
            # ],
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create a rule for Security Group\n")


#######################################################################################################################
#############################################    Security-Group     ################################################
#######################################################################################################################

def get_default_security_group_id_from_vpc(logger=None,
                                           region_name="",
                                           vpc_id="",
                                           aws_access_key_id="",
                                           aws_secret_access_key="",
                                           log_indentation=""
                                           ):
    logger.info(log_indentation + "START: Create Network-Interface")

    ##### Step 01: Use credential to get AWS "Client" || "Resource" objects
    ec2_resource = boto3.resource(
        service_name='ec2',
        region_name=region_name,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 02: Get the VPC
        vpc = ec2_resource.Vpc(vpc_id)


        ##### Step 03: Get a list of Security-Group object from the VPC
        security_group_list = vpc.security_groups.all()


        ##### Step 04: Get all ID of each Security-Group
        # print("\n\nGet all ID of each Security-Group")
        security_group_id_list = list()

        for security_group in security_group_list:
            # print(type(security_group))  # It's a security group object  -->  <class 'boto3.resources.factory.ec2.SecurityGroup'>
            # print(security_group)
            # print(security_group.id)
            security_group_id_list.append(security_group.id)
        # END for


        ##### Step 05: Iterate each Security-Group ID
        # print("\n\nIterate each Security-Group ID...")
        default_security_group_id = None

        for security_group_id in security_group_id_list:
            security_group = ec2_resource.SecurityGroup(security_group_id)
            # print(security_group.group_name)
            if security_group.group_name == "default":  # KEY-POINT!!!!!!!!!!!!!!
                # print("FOUND!!")
                default_security_group_id = security_group_id
        # END for

        return default_security_group_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Network-Interface\n")
# END get_default_security_group_id_from_vpc()





#######################################################################################################################
#############################################    Network-Interface     ################################################
#######################################################################################################################
def create_network_interface(logger=None,
                             region="",
                             subnet_id="",
                             security_group_id_list="",
                             description="",
                             aws_access_key_id="",
                             aws_secret_access_key="",
                             log_indentation=""
                             ):
    logger.info(log_indentation + "START: Create Network-Interface")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create Network-Interface
        response = ec2_client.create_network_interface(
            Description=description,
            SubnetId=subnet_id,
            Groups=security_group_id_list,
            # Ipv6AddressCount=123,
            # Ipv6Addresses=[
            #     {
            #         'Ipv6Address': 'string'
            #     },
            # ],
            # PrivateIpAddress='string',
            # PrivateIpAddresses=[
            #     {
            #         'Primary': True | False,
            #         'PrivateIpAddress': 'string'
            #     },
            # ],
            # SecondaryPrivateIpAddressCount=123,
            DryRun=False,
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Network-Interface ID
        network_interface_id = response["NetworkInterface"]["NetworkInterfaceId"]
        logger.info(log_indentation + "    Network-Interface ID: " + network_interface_id)
        return network_interface_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Network-Interface\n")


def delete_network_interface(logger=None,
                             region="",
                             network_interface_id="",
                             aws_access_key_id="",
                             aws_secret_access_key="",
                             log_indentation=""
                             ):
    logger.info(log_indentation + "START: Delete Network-Interface")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete Network-Interface
        response = ec2_client.delete_network_interface(
            NetworkInterfaceId=network_interface_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return network_interface_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Network-Interface\n")


#######################################################################################################################
#################################################    Volume     #######################################################
#######################################################################################################################
def create_volume(logger=None,
                  region="",
                  availability_zone="",
                  size="",
                  aws_access_key_id="",
                  aws_secret_access_key="",
                  log_indentation=""
                  ):
    logger.info(log_indentation + "START: Create Volume")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create Volume
        response = ec2_client.create_volume(
            AvailabilityZone=availability_zone,
            VolumeType="gp2",  # 'standard' | 'io1' | 'gp2' | 'sc1' | 'st1',
            Size=size,
            Encrypted=False,
            # KmsKeyId='string',
            # Iops=123,  # The number of I/O operations per second that the volume can support.
            # SnapshotId='string',
            # TagSpecifications=[
            #     {
            #         'ResourceType': 'customer-gateway' | 'dhcp-options' | 'image' | 'instance' | 'internet-gateway' | 'network-acl' | 'network-interface' | 'reserved-instances' | 'route-table' | 'snapshot' | 'spot-instances-request' | 'subnet' | 'security-group' | 'volume' | 'vpc' | 'vpn-connection' | 'vpn-gateway',
            #         'Tags': [
            #             {
            #                 'Key': 'string',
            #                 'Value': 'string'
            #             },
            #         ]
            #     },
            # ],
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Volume ID
        volume_id = response["VolumeId"]
        logger.info(log_indentation + "    Volume ID: " + volume_id)
        return volume_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Volume\n")


def delete_volume(logger=None, 
                  region="", 
                  volume_id="", 
                  aws_access_key_id="", 
                  aws_secret_access_key="",
                  log_indentation=""
                  ):
    logger.info(log_indentation + "START: Delete Volume")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete Volume
        response = ec2_client.delete_volume(
            VolumeId=volume_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Volume\n")


#######################################################################################################################
#################################################    Key Pair     #######################################################
#######################################################################################################################
def create_key_pair(logger=None, 
                    region="", 
                    key_pair_name="", 
                    aws_access_key_id="", 
                    aws_secret_access_key="",
                    log_indentation=""
                    ):
    logger.info(log_indentation + "START: Create Key-Pair")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create Key-Pair
        response = ec2_client.create_key_pair(
            KeyName=key_pair_name,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        private_key = response["KeyMaterial"]
        return private_key

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Key-Pair\n")


def delete_key_pair(logger=None, 
                    region="", 
                    key_pair_name="", 
                    aws_access_key_id="", 
                    aws_secret_access_key="",
                    log_indentation=""
                    ):
    logger.info(log_indentation + "START: Delete Key-Pair")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete Key-Pair
        response = ec2_client.delete_key_pair(
            KeyName=key_pair_name,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Key-Pair\n")


#######################################################################################################################
#################################    EC2 Instance / VM / Virtual Machine     ##########################################
#######################################################################################################################
'''
Associate IAM-Instance-Profile to a EC2 Instance
'''
def associate_iam_instance_profile_to_ec2_instance(
        logger=None,
        region="",
        iam_instance_profile_arn="",
        ec2_instance_id="",
        aws_access_key_id="",
        aws_secret_access_key="",
        log_indentation=""
        ):
    logger.info(log_indentation + "START: Associate IAM-Instance-Profile to a EC2 Instance")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Associate IAM-Instance-Profile to a EC2 Instance
        response = ec2_client.associate_iam_instance_profile(
            IamInstanceProfile={
                'Arn': iam_instance_profile_arn
                # 'Name': iam_instance_profile_name
            },
            InstanceId=ec2_instance_id
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Association ID (for disassociation)
        association_id_for_instance_profile_and_ec2_instance = response["IamInstanceProfileAssociation"][
            "AssociationId"]
        logger.info(log_indentation + "    Association ID: " + association_id_for_instance_profile_and_ec2_instance)

        return association_id_for_instance_profile_and_ec2_instance

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Associate IAM-Instance-Profile to a EC2 Instance\n")


def disassociate_iam_instance_profile_from_ec2_instance(
        logger=None,
        region="",
        association_id_for_instance_profile_and_ec2_instance="",
        aws_access_key_id="",
        aws_secret_access_key="",
        log_indentation=""
        ):
    logger.info(log_indentation + "START: Disassociate IAM-Instance-Profile from an EC2 Instance")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Disassociate IAM-Instance-Profile from an EC2 Instance
        response = ec2_client.disassociate_iam_instance_profile(
            AssociationId=association_id_for_instance_profile_and_ec2_instance
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Disassociate IAM-Instance-Profile from an EC2 Instance\n")


'''
Create EC2 Instance/VM
'''
def run_instance(logger=None,
                 region="",
                 ami_id="",
                 subnet_id="",
                 instance_type="",
                 vm_name="",
                 key_pair_name="",
                 security_group_id="",
                 auto_assign_public_ip=False,
                 # iam_instance_profile_name="",
                 iam_instance_profile_arn="",
                 # network_interface_id="",
                 aws_access_key_id="",
                 aws_secret_access_key="",
                 log_indentation=""
                 ):
    ### IF auto_assign_public_ip is True, call another method to do the job
    if auto_assign_public_ip is True:
        instance_id, instance_private_ip = _run_instance_and_auto_assign_public_ip(
            logger=logger,
            region=region,
            ami_id=ami_id,
            subnet_id=subnet_id,
            instance_type=instance_type,
            vm_name=vm_name,
            key_pair_name=key_pair_name,
            security_group_id=security_group_id,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation="    "
        )
        return instance_id, instance_private_ip
    # END IF auto_assign_public_ip is True

    # At this point, user decide to create an EC2 instance without auto_assign a default public IP

    logger.info(log_indentation + "START: Create EC2 Instance/VM")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create EC2 Instance/VM
        response = ec2_client.run_instances(
            ImageId=ami_id,
            SubnetId=subnet_id,
            InstanceType=instance_type,  # 't1.micro' | 't2.nano' | 't2.micro' | 't2.small' | 't2.medium' | 't2.large' | 't2.xlarge' | 't2.2xlarge' | 'm1.small' | 'm1.medium' | 'm1.large' | 'm1.xlarge' | 'm3.medium' | 'm3.large' | 'm3.xlarge' | 'm3.2xlarge' | 'm4.large' | 'm4.xlarge' | 'm4.2xlarge' | 'm4.4xlarge' | 'm4.10xlarge' | 'm4.16xlarge' | 'm2.xlarge' | 'm2.2xlarge' | 'm2.4xlarge' | 'cr1.8xlarge' | 'r3.large' | 'r3.xlarge' | 'r3.2xlarge' | 'r3.4xlarge' | 'r3.8xlarge' | 'r4.large' | 'r4.xlarge' | 'r4.2xlarge' | 'r4.4xlarge' | 'r4.8xlarge' | 'r4.16xlarge' | 'x1.16xlarge' | 'x1.32xlarge' | 'x1e.xlarge' | 'x1e.2xlarge' | 'x1e.4xlarge' | 'x1e.8xlarge' | 'x1e.16xlarge' | 'x1e.32xlarge' | 'i2.xlarge' | 'i2.2xlarge' | 'i2.4xlarge' | 'i2.8xlarge' | 'i3.large' | 'i3.xlarge' | 'i3.2xlarge' | 'i3.4xlarge' | 'i3.8xlarge' | 'i3.16xlarge' | 'hi1.4xlarge' | 'hs1.8xlarge' | 'c1.medium' | 'c1.xlarge' | 'c3.large' | 'c3.xlarge' | 'c3.2xlarge' | 'c3.4xlarge' | 'c3.8xlarge' | 'c4.large' | 'c4.xlarge' | 'c4.2xlarge' | 'c4.4xlarge' | 'c4.8xlarge' | 'c5.large' | 'c5.xlarge' | 'c5.2xlarge' | 'c5.4xlarge' | 'c5.9xlarge' | 'c5.18xlarge' | 'cc1.4xlarge' | 'cc2.8xlarge' | 'g2.2xlarge' | 'g2.8xlarge' | 'g3.4xlarge' | 'g3.8xlarge' | 'g3.16xlarge' | 'cg1.4xlarge' | 'p2.xlarge' | 'p2.8xlarge' | 'p2.16xlarge' | 'p3.2xlarge' | 'p3.8xlarge' | 'p3.16xlarge' | 'd2.xlarge' | 'd2.2xlarge' | 'd2.4xlarge' | 'd2.8xlarge' | 'f1.2xlarge' | 'f1.16xlarge' | 'm5.large' | 'm5.xlarge' | 'm5.2xlarge' | 'm5.4xlarge' | 'm5.12xlarge' | 'm5.24xlarge' | 'h1.2xlarge' | 'h1.4xlarge' | 'h1.8xlarge' | 'h1.16xlarge'
            KeyName=key_pair_name,
            IamInstanceProfile={
                'Arn': iam_instance_profile_arn      # Either passing Arn or Name. Can't pass both
                # 'Name': iam_instance_profile_name  # Either passing Arn or Name. Can't pass both
            },
            SecurityGroupIds=[
                security_group_id,
            ],
            # SecurityGroups=[
            #     'string',
            # ],
            BlockDeviceMappings=[
                {
                    'DeviceName': "/dev/sda1",
                    # 'VirtualName': 'string',
                    'Ebs': {
                        # 'Encrypted': False,
                        'DeleteOnTermination': True,
                        # 'Iops': 123,
                        # 'KmsKeyId': 'string',
                        # 'SnapshotId': 'string',
                        'VolumeSize': 8,
                        'VolumeType': "gp2"  # 'standard' | 'io1' | 'gp2' | 'sc1' | 'st1'
                    },
                    # 'NoDevice': 'string'
                },
            ],
            # PrivateIpAddress='string',
            InstanceInitiatedShutdownBehavior="terminate",  # 'stop' | 'terminate'
            # NetworkInterfaces=[
            #     {
            #         'SubnetId': subnet_id,
            #         'AssociatePublicIpAddress': True,
            #         'DeleteOnTermination': True,
            #         # 'Description': 'string',
            #         'DeviceIndex': 0,
            #         'Groups': [
            #             security_group_id,
            #         ],
            #         'Ipv6AddressCount': 123,
            #         'Ipv6Addresses': [
            #             {
            #                 'Ipv6Address': 'string'
            #             },
            #         ],
            #         'NetworkInterfaceId': network_interface_id,
            #         'PrivateIpAddress': 'string',
            #         'PrivateIpAddresses': [
            #             {
            #                 'Primary': True | False,
            #                 'PrivateIpAddress': 'string'
            #             },
            #         ],
            #         'SecondaryPrivateIpAddressCount': 123,
            #     },
            # ],
            TagSpecifications=[
                {
                    'ResourceType': "instance",
                # 'customer-gateway' | 'dhcp-options' | 'image' | 'instance' | 'internet-gateway' | 'network-acl' | 'network-interface' | 'reserved-instances' | 'route-table' | 'snapshot' | 'spot-instances-request' | 'subnet' | 'security-group' | 'volume' | 'vpc' | 'vpn-connection' | 'vpn-gateway'
                    'Tags': [
                        {
                            'Key': 'Name',
                            'Value': vm_name
                        },
                    ]
                },
            ],
            MaxCount=1,
            MinCount=1,
            # Ipv6AddressCount=123,
            # Ipv6Addresses=[
            #     {
            #         'Ipv6Address': 'string'
            #     },
            # ],
            # KernelId='string',
            # Monitoring={
            #     'Enabled': True | False
            # },
            # Placement={
            #     'AvailabilityZone': 'string',
            #     'Affinity': 'string',
            #     'GroupName': 'string',
            #     'HostId': 'string',
            #     'Tenancy': 'default' | 'dedicated' | 'host',
            #     'SpreadDomain': 'string'
            # },
            # RamdiskId='string',
            # UserData='string',
            # AdditionalInfo='string',
            # ClientToken='string',
            # DisableApiTermination=True | False,
            # EbsOptimized=True | False,
            #
            # ElasticGpuSpecification=[
            #     {
            #         'Type': 'string'
            #     },
            # ],
            # LaunchTemplate={
            #     'LaunchTemplateId': 'string',
            #     'LaunchTemplateName': 'string',
            #     'Version': 'string'
            # },
            # InstanceMarketOptions={
            #     'MarketType': 'spot',
            #     'SpotOptions': {
            #         'MaxPrice': 'string',
            #         'SpotInstanceType': 'one-time' | 'persistent',
            #         'BlockDurationMinutes': 123,
            #         'ValidUntil': datetime(2015, 1, 1),
            #         'InstanceInterruptionBehavior': 'hibernate' | 'stop' | 'terminate'
            #     }
            # },
            # CreditSpecification={
            #     'CpuCredits': 'string'
            # },
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Instance ID & Private IP & auto-assigned Public IP
        instance_id         = response["Instances"][0]["InstanceId"]
        instance_private_ip = response["Instances"][0]["PrivateIpAddress"]

        logger.info(log_indentation + "    Instance ID: " + instance_id)


        return instance_id, instance_private_ip

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create EC2 Instance/VM\n")
# END _run_instance()


def _run_instance_and_auto_assign_public_ip(
                 logger=None,
                 region="",
                 ami_id="",
                 subnet_id="",
                 instance_type="",
                 vm_name="",
                 key_pair_name="",
                 security_group_id="",
                 # iam_instance_profile_name="",
                 iam_instance_profile_arn="",
                 # network_interface_id="",
                 aws_access_key_id="",
                 aws_secret_access_key="",
                 log_indentation=""
                 ):
    logger.info(log_indentation + "START: Create EC2 Instance/VM and auto assign public IP")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create EC2 Instance/VM
        response = ec2_client.run_instances(
            ImageId=ami_id,
            # SubnetId=subnet_id,
            InstanceType=instance_type,  # 't1.micro' | 't2.nano' | 't2.micro' | 't2.small' | 't2.medium' | 't2.large' | 't2.xlarge' | 't2.2xlarge' | 'm1.small' | 'm1.medium' | 'm1.large' | 'm1.xlarge' | 'm3.medium' | 'm3.large' | 'm3.xlarge' | 'm3.2xlarge' | 'm4.large' | 'm4.xlarge' | 'm4.2xlarge' | 'm4.4xlarge' | 'm4.10xlarge' | 'm4.16xlarge' | 'm2.xlarge' | 'm2.2xlarge' | 'm2.4xlarge' | 'cr1.8xlarge' | 'r3.large' | 'r3.xlarge' | 'r3.2xlarge' | 'r3.4xlarge' | 'r3.8xlarge' | 'r4.large' | 'r4.xlarge' | 'r4.2xlarge' | 'r4.4xlarge' | 'r4.8xlarge' | 'r4.16xlarge' | 'x1.16xlarge' | 'x1.32xlarge' | 'x1e.xlarge' | 'x1e.2xlarge' | 'x1e.4xlarge' | 'x1e.8xlarge' | 'x1e.16xlarge' | 'x1e.32xlarge' | 'i2.xlarge' | 'i2.2xlarge' | 'i2.4xlarge' | 'i2.8xlarge' | 'i3.large' | 'i3.xlarge' | 'i3.2xlarge' | 'i3.4xlarge' | 'i3.8xlarge' | 'i3.16xlarge' | 'hi1.4xlarge' | 'hs1.8xlarge' | 'c1.medium' | 'c1.xlarge' | 'c3.large' | 'c3.xlarge' | 'c3.2xlarge' | 'c3.4xlarge' | 'c3.8xlarge' | 'c4.large' | 'c4.xlarge' | 'c4.2xlarge' | 'c4.4xlarge' | 'c4.8xlarge' | 'c5.large' | 'c5.xlarge' | 'c5.2xlarge' | 'c5.4xlarge' | 'c5.9xlarge' | 'c5.18xlarge' | 'cc1.4xlarge' | 'cc2.8xlarge' | 'g2.2xlarge' | 'g2.8xlarge' | 'g3.4xlarge' | 'g3.8xlarge' | 'g3.16xlarge' | 'cg1.4xlarge' | 'p2.xlarge' | 'p2.8xlarge' | 'p2.16xlarge' | 'p3.2xlarge' | 'p3.8xlarge' | 'p3.16xlarge' | 'd2.xlarge' | 'd2.2xlarge' | 'd2.4xlarge' | 'd2.8xlarge' | 'f1.2xlarge' | 'f1.16xlarge' | 'm5.large' | 'm5.xlarge' | 'm5.2xlarge' | 'm5.4xlarge' | 'm5.12xlarge' | 'm5.24xlarge' | 'h1.2xlarge' | 'h1.4xlarge' | 'h1.8xlarge' | 'h1.16xlarge'
            KeyName=key_pair_name,
            IamInstanceProfile={
                'Arn': iam_instance_profile_arn      # Either passing Arn or Name. Can't pass both
                # 'Name': iam_instance_profile_name  # Either passing Arn or Name. Can't pass both
            },
            # SecurityGroupIds=[
            #     security_group_id,
            # ],
            # SecurityGroups=[
            #     'string',
            # ],
            BlockDeviceMappings=[
                {
                    'DeviceName': "/dev/sda1",
                    # 'VirtualName': 'string',
                    'Ebs': {
                        # 'Encrypted': False,
                        'DeleteOnTermination': True,
                        # 'Iops': 123,
                        # 'KmsKeyId': 'string',
                        # 'SnapshotId': 'string',
                        'VolumeSize': 8,
                        'VolumeType': "gp2"  # 'standard' | 'io1' | 'gp2' | 'sc1' | 'st1'
                    },
                    # 'NoDevice': 'string'
                },
            ],
            # PrivateIpAddress='string',
            InstanceInitiatedShutdownBehavior="terminate",  # 'stop' | 'terminate'
            NetworkInterfaces=[
                {
                    'SubnetId': subnet_id,
                    'AssociatePublicIpAddress': True,
                    'DeleteOnTermination': True,
                    # 'Description': 'string',
                    'DeviceIndex': 0,
                    'Groups': [
                        security_group_id,
                    ],
                #     'Ipv6AddressCount': 123,
                #     'Ipv6Addresses': [
                #         {
                #             'Ipv6Address': 'string'
                #         },
                #     ],
                #     'NetworkInterfaceId': network_interface_id,
                #     'PrivateIpAddress': 'string',
                #     'PrivateIpAddresses': [
                #         {
                #             'Primary': True | False,
                #             'PrivateIpAddress': 'string'
                #         },
                #     ],
                #     'SecondaryPrivateIpAddressCount': 123,
                }
            ],
            TagSpecifications=[
                {
                    'ResourceType': "instance",
                # 'customer-gateway' | 'dhcp-options' | 'image' | 'instance' | 'internet-gateway' | 'network-acl' | 'network-interface' | 'reserved-instances' | 'route-table' | 'snapshot' | 'spot-instances-request' | 'subnet' | 'security-group' | 'volume' | 'vpc' | 'vpn-connection' | 'vpn-gateway'
                    'Tags': [
                        {
                            'Key': 'Name',
                            'Value': vm_name
                        },
                    ]
                },
            ],
            MaxCount=1,
            MinCount=1,
            # Ipv6AddressCount=123,
            # Ipv6Addresses=[
            #     {
            #         'Ipv6Address': 'string'
            #     },
            # ],
            # KernelId='string',
            # Monitoring={
            #     'Enabled': True | False
            # },
            # Placement={
            #     'AvailabilityZone': 'string',
            #     'Affinity': 'string',
            #     'GroupName': 'string',
            #     'HostId': 'string',
            #     'Tenancy': 'default' | 'dedicated' | 'host',
            #     'SpreadDomain': 'string'
            # },
            # RamdiskId='string',
            # UserData='string',
            # AdditionalInfo='string',
            # ClientToken='string',
            # DisableApiTermination=True | False,
            # EbsOptimized=True | False,
            #
            # ElasticGpuSpecification=[
            #     {
            #         'Type': 'string'
            #     },
            # ],
            # LaunchTemplate={
            #     'LaunchTemplateId': 'string',
            #     'LaunchTemplateName': 'string',
            #     'Version': 'string'
            # },
            # InstanceMarketOptions={
            #     'MarketType': 'spot',
            #     'SpotOptions': {
            #         'MaxPrice': 'string',
            #         'SpotInstanceType': 'one-time' | 'persistent',
            #         'BlockDurationMinutes': 123,
            #         'ValidUntil': datetime(2015, 1, 1),
            #         'InstanceInterruptionBehavior': 'hibernate' | 'stop' | 'terminate'
            #     }
            # },
            # CreditSpecification={
            #     'CpuCredits': 'string'
            # },
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Instance ID & Private IP & auto-assigned Public IP
        instance_id         = response["Instances"][0]["InstanceId"]
        instance_private_ip = response["Instances"][0]["PrivateIpAddress"]

        logger.info(log_indentation + "    Instance ID: " + instance_id)


        return instance_id, instance_private_ip

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create EC2 Instance/VM and auto assign public IP\n")
# END _run_instance_and_auto_assign_public_ip()


def terminate_instances(logger=None,
                        region="",
                        instance_id_list="",
                        aws_access_key_id="",
                        aws_secret_access_key="",
                        log_indentation=""
                        ):
    logger.info(log_indentation + "START: Terminate Instances")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Terminate Instances
        response = ec2_client.terminate_instances(
            InstanceIds=instance_id_list,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Terminate Instances\n")


def describe_instance_status(logger=None, 
                             region="", 
                             instance_id_list="", 
                             aws_access_key_id="", 
                             aws_secret_access_key="",
                             log_indentation=""
                             ):
    logger.info(log_indentation + "START: Describe EC2 Instance Status")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Describe Instance Status
        response = ec2_client.describe_instance_status(
            # Filters=[
            #     {
            #         'Name': 'string',
            #         'Values': [
            #             'string',
            #         ]
            #     },
            # ],
            InstanceIds=instance_id_list,
            # MaxResults=123,
            # NextToken='string',
            # IncludeAllInstances=True | False,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))  # logger.info(response)  -->>  {'InstanceStatuses': [{'AvailabilityZone': 'ca-central-1b', 'InstanceId': 'i-0bae4085922aa1cbf', 'InstanceState': {'Code': 16, 'Name': 'running'}, 'InstanceStatus': {'Details': [{'Name': 'reachability', 'Status': 'passed'}], 'Status': 'ok'}, 'SystemStatus': {'Details': [{'Name': 'reachability', 'Status': 'passed'}], 'Status': 'ok'}}], 'ResponseMetadata': {'RequestId': '06aee78b-a6b6-4bdd-9328-3d4979d22824', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 18:28:02 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}

        ##### Step 02: Get Status
        instance_state         = response["InstanceStatuses"][0]["InstanceState"]["Name"]
        instance_system_status = response["InstanceStatuses"][0]["SystemStatus"]["Status"]
        logger.info(log_indentation + "    Instance State:         " + instance_state)
        logger.info(log_indentation + "    Instance System Status: " + instance_system_status)
        return instance_state, instance_system_status

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Describe EC2 Instance Status\n")


def describe_instance_attribute(logger=None, 
                                region="", 
                                instance_id="", 
                                attribute="", 
                                aws_access_key_id="", 
                                aws_secret_access_key="",
                                log_indentation=""
                                ):
    logger.info(log_indentation + "START: Describe Instance Attribute")

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)

    try:
        ##### Step 01: Describe Instance Attribute
        response = ec2_client.describe_instance_attribute(
            Attribute=attribute,  # Valid Value: 'instanceType' | 'kernel' | 'ramdisk' | 'userData' | 'disableApiTermination' | 'instanceInitiatedShutdownBehavior' | 'rootDeviceName' | 'blockDeviceMapping' | 'productCodes' | 'sourceDestCheck' | 'groupSet' | 'ebsOptimized' | 'sriovNetSupport' | 'enaSupport',
            InstanceId=instance_id,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return response

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Describe Instance Attribute\n")


def describe_instances(logger=None,
                       region="",
                       instance_id_list="",
                       aws_access_key_id="",
                       aws_secret_access_key="",
                       log_indentation=""
                       ):
    logger.info(log_indentation + "START: Describe EC2 Instances")

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)

    try:
        ##### Step 01: Describe EC2 Instances
        response = ec2_client.describe_instances(
            # Filters=[
            #     {
            #         'Name': 'string',
            #         'Values': [
            #             'string',
            #         ]
            #     },
            # ],
            InstanceIds=instance_id_list,
            DryRun=False
            # MaxResults=123,
            # NextToken='string'
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return response

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Describe EC2 Instances\n")


def describe_iam_instance_profile_associations(logger=None, 
                                               region="", 
                                               instance_id="",
                                               aws_access_key_id="",
                                               aws_secret_access_key="",
                                               log_indentation=""
                                               ):
    logger.info(log_indentation + "START: Describe IAM Instance Profile Associations for Instance: " + 
                instance_id + " in " + region)

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)

    try:
        ##### Step 01: Describe IAM Instance Profile Associations
        response = ec2_client.describe_iam_instance_profile_associations(
            # AssociationIds=[
            #     'string',
            # ],
            Filters=[
                {
                    'Name': 'instance-id',
                    'Values': [
                        instance_id,
                    ]
                },
            ],
            # MaxResults=123,
            # NextToken='string'
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))  # logger.info(response)  -->>  {'IamInstanceProfileAssociations': [{'AssociationId': 'iip-assoc-0366ca256cba98d83', 'InstanceId': 'i-0805e7138f8e540e1', 'IamInstanceProfile': {'Arn': 'arn:aws:iam::971302066566:instance-profile/byol-AviatrixInstanceProfile-1IWGARA2GOKHJ', 'Id': 'AIPAJQF4LCA6NR6L2SOWG'}, 'State': 'associated'}], 'ResponseMetadata': {'RequestId': '747594ad-35a6-43ae-a850-445c9c9623c0', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 19:58:55 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}

        ##### Step 02: Get Association-ID between Profile-Instance and EC2 Instance
        association_id = response["IamInstanceProfileAssociations"][0]["AssociationId"]
        logger.info(log_indentation + "    Association-ID between Profile-Instance and EC2 Instance: " + association_id)

        ##### Step 03: Get Profile-Instance ARN
        instance_profile_arn = response["IamInstanceProfileAssociations"][0]["IamInstanceProfile"]["Arn"]
        logger.info(log_indentation + "    Instance Profile ARN                                    : " + instance_profile_arn)

        return association_id, instance_profile_arn

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Describe IAM Instance Profile Associations for Instance: " + instance_id + " in " + region + "\n")


#######################################################################################################################
############################################    Elastic IP (EIP)     ##################################################
#######################################################################################################################
def allocate_eip(logger=None, region="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info("START: Allocate EIP")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Allocate EIP
        response = ec2_client.allocate_address(
            Domain="standard",  # 'vpc' | 'standard',
            # Address='string',
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get EIP ID
        eip_id = response["AllocationId"]
        eip    = response["PublicIp"]
        logger.info(log_indentation + "    EIP ID: " + eip_id)
        logger.info(log_indentation + "    EIP   : " + eip)
        return (eip_id, eip)

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Allocate EIP\n")


def release_address(logger=None,
                    region="",
                    eip_id="",
                    aws_access_key_id="",
                    aws_secret_access_key="",
                    log_indentation=""
                    ):
    """
    This function release/delete an EIP 
    :return: return True if no error/exception occurs
    """
    logger.info(log_indentation + "START: Release EIP")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Release EIP
        response = ec2_client.release_address(
            AllocationId=eip_id,
            # PublicIp=eip,
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Release EIP\n")


def associate_address(logger=None, 
                      region="", 
                      eip="", 
                      instance_id="", 
                      aws_access_key_id="", 
                      aws_secret_access_key="",
                      log_indentation=""
                      ):
    """
    This AWS API associate an EIP to an EC2 instance(VM)
    :return: This function returns True if no error/exception occurs
    """
    logger.info(log_indentation + "START: Associate EIP to EC2 Instance")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Associate EIP to EC2 Instance
        response = ec2_client.associate_address(
            # AllocationId='string',
            InstanceId=instance_id,
            PublicIp=eip,
            AllowReassociation=False,
            # NetworkInterfaceId='string',
            # PrivateIpAddress='string',
            DryRun=False,
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        eip_association_id = response["AssociationId"]
        logger.info(log_indentation + "AssociationId: " + eip_association_id)
        return eip_association_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Associate EIP to EC2 Instance\n")


def disassociate_address(logger=None, 
                         region="", 
                         eip_association_id="", 
                         aws_access_key_id="", 
                         aws_secret_access_key="",
                         log_indentation=""
                         ):
    logger.info(log_indentation + "START: Disassociate EIP from an EC2 instance")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Disassociate EIP from instance
        response = ec2_client.disassociate_address(
            AssociationId=eip_association_id,
            # PublicIp='string',
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Disassociate EIP from instance\n")


def describe_addresses(logger=None, region="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Describe EIPs")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Describe EIPs
        response = ec2_client.describe_addresses(
            # Filters=[
            #     {
            #         'Name': 'string',
            #         'Values': [
            #             'string',
            #         ]
            #     },
            # ],
            # PublicIps=[
            #     'string',
            # ],
            # AllocationIds=[
            #     'string',
            # ],
            DryRun=False
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))  # -->>  {'Addresses': [{'InstanceId': 'i-0805e7138f8e540e1', 'PublicIp': '35.182.94.13', 'AllocationId': 'eipalloc-6f133641', 'AssociationId': 'eipassoc-ccebf406', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-9085a1c5', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.7.96'}, {'InstanceId': 'i-0ac9916bd87167dff', 'PublicIp': '52.60.65.87', 'AllocationId': 'eipalloc-1d301533', 'AssociationId': 'eipassoc-c8243b02', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-4d341018', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.3.205', 'Tags': [{'Key': 'Description', 'Value': 'Created by Aviatrix gateway gw1, please do NOT remove it.'}, {'Key': 'Name', 'Value': 'Aviatrix-eip@gw1-52.60.65.87'}]}], 'ResponseMetadata': {'RequestId': '8fcf2bb5-f44a-4645-9d5f-4c891ac2a826', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 21:29:52 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}
        return response

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Describe EIPs\n")


"""
Check if an EC2 Instance is using EIP or not
"""
def is_instance_attached_eip(logger=None, 
                             region="", 
                             instance_id="", 
                             aws_access_key_id="", 
                             aws_secret_access_key="",
                             log_indentation=""
                             ):
    logger.info(log_indentation + "START: Check if an EC2 Instance is using EIP")

    ec2_client = boto3.client(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Describe EIPs
        response = ec2_client.describe_addresses(
            # Filters=[
            #     {
            #         'Name': 'string',
            #         'Values': [
            #             'string',
            #         ]
            #     },
            # ],
            # PublicIps=[
            #     'string',
            # ],
            # AllocationIds=[
            #     'string',
            # ],
            DryRun=False
        )
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))  # logger.info(response)  # -->>  {'Addresses': [{'InstanceId': 'i-0805e7138f8e540e1', 'PublicIp': '35.182.94.13', 'AllocationId': 'eipalloc-6f133641', 'AssociationId': 'eipassoc-ccebf406', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-9085a1c5', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.7.96'}, {'InstanceId': 'i-0ac9916bd87167dff', 'PublicIp': '52.60.65.87', 'AllocationId': 'eipalloc-1d301533', 'AssociationId': 'eipassoc-c8243b02', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-4d341018', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.3.205', 'Tags': [{'Key': 'Description', 'Value': 'Created by Aviatrix gateway gw1, please do NOT remove it.'}, {'Key': 'Name', 'Value': 'Aviatrix-eip@gw1-52.60.65.87'}]}], 'ResponseMetadata': {'RequestId': '8fcf2bb5-f44a-4645-9d5f-4c891ac2a826', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 21:29:52 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}
        eips = response["Addresses"]
        found = False

        # Iterate through all EIPs
        for i in range(len(eips)):
            instance_id = eips[i]["InstanceId"]
            if instance_id == instance_id:
                found = True
                break
        # END for

        return found


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Check if an EC2 Instance is using EIP\n")


def aws_create_vpc(aws_access_key_id=None,
                   aws_secret_access_key=None,
                   region_name=None,
                   vpc_cidr=None,
                   vpc_name_tag=None,
                   subnet_cidr=None,
                   create_instance=False,
                   cfg_file=""):

    vpc_cfg = {}
    ec2 = boto3.resource('ec2',
                         aws_access_key_id=aws_access_key_id,
                         aws_secret_access_key=aws_secret_access_key,
                         region_name=region_name)

    # create VPC
    vpc = request_api.execute(ec2.create_vpc, CidrBlock=vpc_cidr)
    time.sleep(10)
    vpc.wait_until_available()
    vpc.wait_until_exists()

    # we can assign a name to vpc, or any resource, by using tag
    request_api.execute(vpc.create_tags, Tags=[{"Key": "Name", "Value": vpc_name_tag}])

    logger.info('vpc_id: {}'.format(vpc.id))

    vpc_cfg["vpc_name_tag"] = vpc_name_tag
    vpc_cfg["vpc_cidr"] = vpc_cidr
    vpc_cfg["vpc_id"] = vpc.id
    vpc_cfg["vpc_region"] = region_name

    # create then attach internet gateway
    ig = request_api.execute(ec2.create_internet_gateway)
    request_api.execute(vpc.attach_internet_gateway, InternetGatewayId=ig.id)
    logger.info('ig_id: {}'.format(ig.id))
    vpc_cfg["igw_id"] = ig.id

    # create a route table and a public route
    route_table = request_api.execute(vpc.create_route_table)
    route = request_api.execute(route_table.create_route,
        DestinationCidrBlock='0.0.0.0/0',
        GatewayId=ig.id
    )
    logger.info('route_table_id: {}'.format(route_table.id))
    vpc_cfg["rtb_id"] = route_table.id

    # create subnet
    subnet_name = vpc_name_tag + '-public'
    subnet = request_api.execute(ec2.create_subnet, CidrBlock=subnet_cidr, VpcId=vpc.id)
    request_api.execute(subnet.create_tags, Tags=[{"Key": "Name", "Value": subnet_name}])
    logger.info('subnet_id: {}'.format(subnet.id))
    vpc_cfg["subnet_name"] = subnet_name
    vpc_cfg["subnet_id"] = subnet.id
    vpc_cfg["subnet_cidr"] = subnet_cidr
    time.sleep(5)

    # associate the route table with the subnet
    request_api.execute(route_table.associate_with_subnet, SubnetId=subnet.id)

    # Create sec group
    sg_name = vpc_name_tag + '-sg'
    sec_group = request_api.execute(ec2.create_security_group,
        GroupName=sg_name, Description=sg_name, VpcId=vpc.id)
    request_api.execute(sec_group.authorize_ingress,
        CidrIp='0.0.0.0/0',
        IpProtocol='icmp',
        FromPort=-1,
        ToPort=-1
    )
    request_api.execute(sec_group.authorize_ingress,
        CidrIp='0.0.0.0/0',
        IpProtocol='tcp',
        FromPort=22,
        ToPort=22
    )
    logger.info('sec_group_id: {}'.format(sec_group.id))
    vpc_cfg["sg_name"] = sg_name
    vpc_cfg["sg_id"] = sec_group.id

    if create_instance:

        # Create ssh key
        key_pair_name = vpc_name_tag + '-sshkey'
        private_key = request_api.execute(create_key_pair,logger=logger,
                                      region=region_name,
                                      key_pair_name=key_pair_name,
                                      aws_access_key_id=aws_access_key_id,
                                      aws_secret_access_key=aws_secret_access_key)
        if not private_key:
            logger.error('SSH key pair can not be created successfully')
            return
        if cfg_file:
            key_file_name = cfg_file + key_pair_name + KEY_EXT
            with open(key_file_name, 'w+') as f:
                f.write(private_key)
            #cmd = 'sudo chmod 400 ' + key_file_name
            #os.system(cmd)
            #os.chmod(key_file_name, 0o400)


        # Acquire AMI ID
        path_to_aws_global_config_file = './Aviatrix_API_Python_Scripts/config_global/aws_config.json'
        aws_config = read_config_file(file_path=path_to_aws_global_config_file)
        if aws_config:
            ami_id = aws_config["AWS"]["AMI"][region_name]["ubuntu_16_04"]

        # Create instance
        instances = request_api.execute(ec2.create_instances,
            KeyName=key_pair_name, ImageId=ami_id, InstanceType='t2.micro', MaxCount=1, MinCount=1,
            NetworkInterfaces=[{'SubnetId': subnet.id, 'DeviceIndex': 0, 'AssociatePublicIpAddress': True,
                                'Groups': [sec_group.group_id]}])
        instances[0].wait_until_running()
        request_api.execute(instances[0].load)
        logger.info('instance_id: {}'.format(instances[0].id))
        logger.info('instance_pubic_ip: {}'.format(instances[0].public_ip_address))
        logger.info('instance_private_ip: {}'.format(instances[0].private_ip_address))
        vpc_cfg["inst_id"] = instances[0].id
        vpc_cfg["inst_public_ip"] = instances[0].public_ip_address
        vpc_cfg["inst_private_ip"] = instances[0].private_ip_address
    if cfg_file:
        cfg_file_path = cfg_file + vpc_name_tag + CFG_EXT
        write_config_file(file_path=cfg_file_path, cfg=vpc_cfg)


def aws_delete_vpc(aws_access_key_id=None,
                   aws_secret_access_key=None,
                   region_name=None,
                   vpc_name_tag=None,
                   vpc_id=None):

    max_retries = 3

    ec2 = boto3.resource('ec2',
                         aws_access_key_id=aws_access_key_id,
                         aws_secret_access_key=aws_secret_access_key,
                         region_name=region_name)
    ec2_client = ec2.meta.client

    vpc = ec2.Vpc(vpc_id)

    # delete any instances
    logger.info('Deleting all instances...')
    for subnet in vpc.subnets.all():
        for instance in subnet.instances.all():
            try:
                request_api.execute(instance.terminate)
            except Exception as e:
                logger.error(str(e))

    #sleep for dependency cleanup
    time.sleep(30)

    for i in range(0, max_retries):
        logger.info("Trying to delete VPC with retry {} ...".format(str(i)))
        try:
            response = ec2_client.describe_vpcs(
                VpcIds=[
                    vpc.id,
                ]
            )
        except Exception as e:
            logger.info(str(e))
            break

        # delete all route table associations
        logger.info('Deleting route tables...')
        for rt in vpc.route_tables.all():
            for rta in rt.associations:
                if not rta.main:
                    try:
                        request_api.execute(rta.delete)
                        request_api.execute(ec2_client.delete_route_table, RouteTableId=rt.id)
                    except Exception as e:
                        logger.error(str(e))

        # delete all subnets
        logger.info('Deleting all subnets...')
        for subnet in vpc.subnets.all():
            for interface in subnet.network_interfaces.all():
                try:
                    request_api.execute(interface.delete)
                except Exception as e:
                    logger.error(str(e))
            try:
                request_api.execute(subnet.delete)
            except Exception as e:
                logger.error(str(e))

        # delete our security groups
        logger.info('Deleting security groups...')
        for sg in vpc.security_groups.all():
            if sg.group_name != 'default':
                try:
                    request_api.execute(sg.delete)
                except Exception as e:
                    logger.error(str(e))

        time.sleep(30)
        # detach and delete all gateways associated with the vpc
        logger.info('Deleting internet gateways...')
        for gw in vpc.internet_gateways.all():
            try:
                request_api.execute(vpc.detach_internet_gateway, InternetGatewayId=gw.id)
                request_api.execute(gw.delete)
            except Exception as e:
                logger.error(str(e))

        time.sleep(30)
        # finally, delete the vpc
        logger.info('Finally, deleting the vpc...')
        try:
            request_api.execute(ec2_client.delete_vpc, VpcId=vpc_id)
        except Exception as e:
            logger.error(str(e))

    # delete key pair
    logger.info('Deleting key pair...')
    key_pair_name = vpc_name_tag + '-sshkey'
    try:
        request_api.execute(ec2_client.delete_key_pair,
            KeyName=key_pair_name,
            DryRun=False
        )
    except Exception as e:
        logger.error(str(e))


def aws_stop_instance(aws_access_key_id=None,
                   aws_secret_access_key=None,
                   region_name=None,
                   instance_id=None):

    ec2 = boto3.resource('ec2',
                         aws_access_key_id=aws_access_key_id,
                         aws_secret_access_key=aws_secret_access_key,
                         region_name=region_name)
    ec2.Instance(instance_id).stop()

