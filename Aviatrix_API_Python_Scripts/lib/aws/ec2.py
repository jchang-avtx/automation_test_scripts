#!/usr/bin/python3
# -*- coding: UTF-8 -*-


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

from lib.aviatrix.aviatrix_util import *
from lib.aviatrix.account import *
from lib.aviatrix.initial_setup import *
from lib.aviatrix.gateway import *
from lib.aviatrix.transit_network import *
from lib.aviatrix.transit_network import *

from lib.aws.account import *
from lib.aws.iam import *

from lib.util.util import *


#######################################################################################################################
#################################################    Tag     ##########################################################
#######################################################################################################################

def create_name_tag(logger=None, region="", resource="", name="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Create Name Tag")

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
        ##### Step 01: Create Name Tag
        response = ec2_client.create_tags(
            Resources=resources,
            Tags=tags,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Create Name Tag\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



#######################################################################################################################
#################################################    VPC     ##########################################################
#######################################################################################################################

def create_vpc(logger=None, region="", cidr="", aws_access_key_id="", aws_secret_access_key="", ):
    logger.info("\nSTART: Create VPC")
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

        ##### Step 02: Get VPC ID
        logger.info("    Successfully created a VPC.")
        vpc_id = response["Vpc"]["VpcId"]
        logger.info("    VPC ID: " + vpc_id)

        ##### Step 03: Wait until VPC is available
        logger.info("    Wait until VPC is available")
        vpc = ec2_resource.Vpc(vpc_id)  # Get VPC object
        vpc.wait_until_available()

        ##### Step 04: Modify VPC Attributes to set "DNS hostnames" to "yes"
        logger.info("    Modify VPC Attributes to set \"DNS hostnames\" to \"yes\"")

        response = ec2_client.modify_vpc_attribute(
            EnableDnsHostnames={
                'Value': True
            },
            VpcId=vpc_id
        )

        logger.info("    Succeed")
        logger.info("ENDED: Create VPC\n")

        return vpc_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False





def delete_vpc(logger=None, region="", vpc_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Delete VPC")
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

        logger.info("    Succeed")
        logger.info("ENDED: Delete VPC\n")
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False





#######################################################################################################################
#################################################    Subnet     #######################################################
#######################################################################################################################

def create_subnet(logger=None,
                  region="",
                  vpc_id="",
                  availability_zone="",
                  cidr="",
                  aws_access_key_id="",
                  aws_secret_access_key=""
                  ):
    logger.info("\nSTART: Create Subnet")

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
        ##### Step 01: Create Subnet
        response = ec2_client.create_subnet(
            AvailabilityZone=availability_zone,
            CidrBlock=cidr,
            # Ipv6CidrBlock='string',
            VpcId=vpc_id,
            DryRun=False
        )

        ##### Step 02: Get Subnet ID
        logger.info("    Successfully created a Subnet.")
        subnet_id = response["Subnet"]["SubnetId"]
        logger.info("    Subnet ID: " + subnet_id)

        ##### Step 03: Wait until Subnet is available
        # logger.info("\n    Wait until Subnet is available\n")
        # subnet = ec2_resource.Subnet(subnet_id)  # Get VPC object
        # subnet.wait_until_available()

        logger.info("ENDED: Create Subnet\n")

        return subnet_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_subnet(logger=None, region="", subnet_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Delete Subnet")

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

        logger.info("    Succeed")
        logger.info("ENDED: Delete Subnet\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



#######################################################################################################################
###################################################    IGW     ########################################################
#######################################################################################################################

def create_igw(logger=None, region="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Create IGW")

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
        ##### Step 01: Create IGW
        response = ec2_client.create_internet_gateway(
            DryRun=False
        )

        ##### Step 02: Get IGW ID
        logger.info("    Succeed")
        igw_id = response["InternetGateway"]["InternetGatewayId"]
        logger.info("    IGW ID: " + igw_id)

        logger.info("ENDED: Create IGW\n")

        return igw_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_igw(logger=None, region="", igw_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Delete IGW")

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
        ##### Step 01: Delete IGW
        response = ec2_client.delete_internet_gateway(
            InternetGatewayId=igw_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete IGW\n")

        return igw_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def attach_igw_to_vpc(logger=None, region="", igw_id="", vpc_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Attach IGW")

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
        ##### Step 01: Attach IGW
        response = ec2_client.attach_internet_gateway(
            InternetGatewayId=igw_id,
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Attach IGW\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def detach_igw_from_vpc(logger=None, region="", igw_id="", vpc_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Detach IGW")

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
        ##### Step 01: Detach IGW
        response = ec2_client.detach_internet_gateway(
            InternetGatewayId=igw_id,
            VpcId=vpc_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Detach IGW\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False




#######################################################################################################################
###############################################    Route Table     ####################################################
#######################################################################################################################


def create_route_table(logger=None, region="", vpc_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Create Route-Table")

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
        ##### Step 01: Create Route-Table
        response = ec2_client.create_route_table(
            VpcId=vpc_id,
            DryRun=False
        )

        ##### Step 02: Get route table ID
        logger.info("    Succeed")
        route_table_id = response["RouteTable"]["RouteTableId"]
        logger.info("    Route-Table ID: " + route_table_id)

        logger.info("ENDED: Create Route-Table\n")

        return route_table_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_route_table(logger=None, region="", route_table_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Delete route table: " + route_table_id)

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
        ##### Step 01: Delete route table
        response = ec2_client.delete_route_table(
            RouteTableId=route_table_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete route table: " + route_table_id + "\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def associate_route_table_to_subnet(logger=None,
                                    region="",
                                    route_table_id="",
                                    subnet_id="",
                                    aws_access_key_id="",
                                    aws_secret_access_key=""
                                    ):
    logger.info("\nSTART: Associate route table to subnet")

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
        ##### Step 01: Associate route table to subnet
        response = ec2_client.associate_route_table(
            RouteTableId=route_table_id,
            SubnetId=subnet_id,
            DryRun=False
        )

        logger.info("    Succeed")
        route_table_association_id = response["AssociationId"]
        logger.info("AssociationId: " + route_table_association_id)
        logger.info("ENDED: Associate route table to subnet\n")

        return route_table_association_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def disassociate_route_table(logger=None,
                             region="",
                             route_table_association_id="",
                             aws_access_key_id="",
                             aws_secret_access_key=""
                             ):
    logger.info("\nSTART: Disassociate route table from subnet")

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
        ##### Step 01:     logger.info("\nSTART: Disassociate route table from subnet")

        response = ec2_client.disassociate_route_table(
            AssociationId=route_table_association_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Disassociate route table from subnet\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def create_route(logger=None,
                 region="",
                 route_table_id="",
                 destnation_cidr="",
                 igw_id="",
                 network_interface_id="",
                 aws_access_key_id="",
                 aws_secret_access_key=""
                 ):
    logger.info("\nSTART: Create route to route-table: " + route_table_id)

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

        logger.info("    Succeed")
        logger.info("ENDED: Create route to route-table: " + route_table_id + "\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_route(logger=None,
                 region="",
                 route_table_id="",
                 destnation_cidr="",
                 aws_access_key_id="",
                 aws_secret_access_key=""
                 ):
    logger.info("\nSTART: Delete Route")

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
        ##### Step 01: Delete Route
        response = ec2_client.delete_route(
            RouteTableId=route_table_id,
            DestinationCidrBlock=destnation_cidr,
            # DestinationIpv6CidrBlock='string',
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete Route\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def get_route_table_id_from_subnet(logger=None,
                                   region="",
                                   subnet_id="",
                                   aws_access_key_id="",
                                   aws_secret_access_key=""
                                   ):
    logger.info("\nSTART: Get route table ID from subnet: " + subnet_id)

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

        ##### Step 02: Get Get route table ID from response
        logger.info("    Succeed")
        route_table_id = response['RouteTables'][0]['Associations'][0]['RouteTableId']
        logger.info("    Route table ID: " + route_table_id)

        logger.info("ENDED: Get route table ID from subnet: " + subnet_id + "\n")

        return route_table_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False




#######################################################################################################################
##########################################    Security Group     ######################################################
#######################################################################################################################


def create_security_group(logger=None,
                          region="",
                          vpc_id="",
                          security_group_name="",
                          description="",
                          aws_access_key_id="",
                          aws_secret_access_key=""
                          ):
    logger.info("\nSTART: Create Security-Group")

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
        ##### Step 01: Create Security-Group
        response = ec2_client.create_security_group(
            VpcId=vpc_id,
            GroupName=security_group_name,
            Description=description,
            DryRun=False
        )

        ##### Step 02: Get Security-Group ID
        logger.info("    Succeed")
        security_group_id = response["GroupId"]
        logger.info("    Security-Group ID: " + security_group_id)

        logger.info("ENDED: Create Security-Group\n")

        return security_group_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_security_group(logger=None,
                          region="",
                          security_group_id="",
                          security_group_name="",
                          aws_access_key_id="",
                          aws_secret_access_key=""
                          ):
    logger.info("\nSTART: Delete Security-Group")

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
        ##### Step 01: Delete Security-Group
        response = ec2_client.delete_security_group(
            GroupId=security_group_id,
            # GroupName=security_group_name,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete Security-Group\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



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
                                     aws_access_key_id=aws_access_key_id,
                                     aws_secret_access_key=aws_secret_access_key
                                     ):
    logger.info("\nSTART: Create a rule for Security Group: " + security_group_id)

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
        ##### Step 01: Create a rule for Security Group
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

        logger.info("    Succeed")
        logger.info("ENDED: Create a rule for Security Group\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



#######################################################################################################################
#############################################    Network-Interface     ################################################
#######################################################################################################################


def create_network_interface(logger=None,
                             region="",
                             subnet_id="",
                             security_group_id_list="",
                             description="",
                             aws_access_key_id=aws_access_key_id,
                             aws_secret_access_key=aws_secret_access_key
                             ):
    logger.info("\nSTART: Create Network-Interface")

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

        ##### Step 02: Get Network-Interface ID
        logger.info("    Succeed")
        network_interface_id = response["NetworkInterface"]["NetworkInterfaceId"]
        logger.info("    Network-Interface ID: " + network_interface_id)


        logger.info("ENDED: Create Network-Interface\n")

        return network_interface_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_network_interface(logger=None,
                             region="",
                             network_interface_id="",
                             aws_access_key_id="",
                             aws_secret_access_key=""
                             ):
    logger.info("\nSTART: Delete Network-Interface")

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
        ##### Step 01: Delete Network-Interface
        response = ec2_client.delete_network_interface(
            NetworkInterfaceId=network_interface_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete Network-Interface\n")

        return network_interface_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



#######################################################################################################################
#################################################    Volume     #######################################################
#######################################################################################################################


def create_volume(logger=None,
                  region="",
                  availability_zone="",
                  size="",
                  aws_access_key_id="",
                  aws_secret_access_key=""):
    logger.info("\nSTART: Create Volume")

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

        ##### Step 02: Get Volume ID
        logger.info("    Succeed")
        volume_id = response["VolumeId"]
        logger.info("    Volume ID: " + volume_id)

        logger.info("ENDED: Create Volume\n")

        return volume_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_volume(logger=None, region="", volume_id="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Delete Volume")

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
        ##### Step 01: Delete Volume
        response = ec2_client.delete_volume(
            VolumeId=volume_id,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete Volume\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



#######################################################################################################################
#################################################    Key Pair     #######################################################
#######################################################################################################################


def create_key_pair(logger=None, region="", key_pair_name="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Create Key-Pair")

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
        ##### Step 01: Create Key-Pair
        response = ec2_client.create_key_pair(
            KeyName=key_pair_name,
            DryRun=False
        )

        logger.info("    Succeed")
        private_key = response["KeyMaterial"]
        logger.info("ENDED: Create Key-Pair\n")

        return private_key


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def delete_key_pair(logger=None, region="", key_pair_name="", aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Delete Key-Pair")

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
        ##### Step 01: Delete Key-Pair
        response = ec2_client.delete_key_pair(
            KeyName=key_pair_name,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Delete Key-Pair\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



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
        aws_secret_access_key=""):
    logger.info("\nSTART: Associate IAM-Instance-Profile to a EC2 Instance")

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)
    ec2_resource = boto3.resource(
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

        ##### Step 02: Get Association ID (for disassociation)
        logger.info("    Succeed")
        association_id_for_instance_profile_and_ec2_instance = response["IamInstanceProfileAssociation"][
            "AssociationId"]
        logger.info("    Association ID: " + association_id_for_instance_profile_and_ec2_instance)

        logger.info("ENDED: Associate IAM-Instance-Profile to a EC2 Instance\n")

        return association_id_for_instance_profile_and_ec2_instance

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False



def disassociate_iam_instance_profile_from_ec2_instance(
        region="",
        association_id_for_instance_profile_and_ec2_instance="",
        aws_access_key_id="",
        aws_secret_access_key=""):
    logger.info("\nSTART: Disassociate IAM-Instance-Profile from an EC2 Instance")

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)
    ec2_resource = boto3.resource(
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
        logger.info("    Succeed")
        logger.info("ENDED: Disassociate IAM-Instance-Profile from an EC2 Instance\n")

        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass


'''
Create EC2 Instance/VM
'''
def run_instance(region="",
                 ami_id="",
                 subnet_id="",
                 instance_type="",
                 vm_name="",
                 key_pair_name="",
                 security_group_id="",
                 iam_instance_profile_name="",
                 iam_instance_profile_arn="",
                 network_interface_id=""
                 ):
    logger.info("\nSTART: Create EC2 Instance/VM")

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

        ##### Step 02: Get Instance ID
        logger.info("    Succeed")
        instance_id         = response["Instances"][0]["InstanceId"]
        instance_private_ip = response["Instances"][0]["PrivateIpAddress"]
        logger.info("    Instance ID: " + instance_id)

        logger.info("ENDED: Create EC2 Instance/VM\n")

        return instance_id, instance_private_ip


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def terminate_instances(region="", instance_id_list=""):
    logger.info("\nSTART: Terminate Instances")

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
        ##### Step 01: Terminate Instances
        response = ec2_client.terminate_instances(
            InstanceIds=instance_id_list,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Terminate Instances\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def describe_instance_status(region="", instance_id_list=""):
    logger.info("\nSTART: Describe Instance Status")

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

        ##### Step 02: Get Status
        logger.info("    Succeed")
        # logger.info(response)  # logger.info(response)  -->>  {'InstanceStatuses': [{'AvailabilityZone': 'ca-central-1b', 'InstanceId': 'i-0bae4085922aa1cbf', 'InstanceState': {'Code': 16, 'Name': 'running'}, 'InstanceStatus': {'Details': [{'Name': 'reachability', 'Status': 'passed'}], 'Status': 'ok'}, 'SystemStatus': {'Details': [{'Name': 'reachability', 'Status': 'passed'}], 'Status': 'ok'}}], 'ResponseMetadata': {'RequestId': '06aee78b-a6b6-4bdd-9328-3d4979d22824', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 18:28:02 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}
        instance_state         = response["InstanceStatuses"][0]["InstanceState"]["Name"]
        instance_system_status = response["InstanceStatuses"][0]["SystemStatus"]["Status"]
        logger.info("    Instance State:         " + instance_state)
        logger.info("    Instance System Status: " + instance_system_status)


        logger.info("ENDED: Describe Instance Status\n")

        return instance_state, instance_system_status


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def describe_instance_attribute(region="", instance_id="", attribute="", param2="", param3="", param4="", param5=""):
    logger.info("\nSTART: Describe Instance Attribute")

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)
    ec2_resource = boto3.resource(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Describe Instance Attribute
        response = ec2_client.describe_instance_attribute(
            Attribute=attribute,  # Valid Value: 'instanceType' | 'kernel' | 'ramdisk' | 'userData' | 'disableApiTermination' | 'instanceInitiatedShutdownBehavior' | 'rootDeviceName' | 'blockDeviceMapping' | 'productCodes' | 'sourceDestCheck' | 'groupSet' | 'ebsOptimized' | 'sriovNetSupport' | 'enaSupport',
            InstanceId=instance_id,
            DryRun=False
        )

        logger.info("    Succeed")
        ##### Step 02: Get response
        logger.info(response)  # result  -->>
        logger.info("ENDED: Describe Instance Attribute\n")

        return response


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def describe_instances(region="", instance_id_list="", param2="", param3="", param4="", param5="", param6=""):
    logger.info("\nSTART: Describe EC2 Instances")

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)
    ec2_resource = boto3.resource(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

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

        logger.info("    Succeed")

        ##### Step 02: Get XXXXX_somthing_XXXXX Attributes
        logger.info(response)  # logger.info(response)  -->>  {'Reservations': [{'Groups': [], 'Instances': [{'AmiLaunchIndex': 0, 'ImageId': 'ami-de4bceba', 'InstanceId': 'i-0bae4085922aa1cbf', 'InstanceType': 't2.large', 'KeyName': 'key_aws_central', 'LaunchTime': datetime.datetime(2018, 3, 12, 10, 30, 47, tzinfo=tzutc()), 'Monitoring': {'State': 'disabled'}, 'Placement': {'AvailabilityZone': 'ca-central-1b', 'GroupName': '', 'Tenancy': 'default'}, 'PrivateDnsName': 'ip-172-31-2-170.ca-central-1.compute.internal', 'PrivateIpAddress': '172.31.2.170', 'ProductCodes': [{'ProductCodeId': 'zemc6exdso42eps9ki88l9za', 'ProductCodeType': 'marketplace'}], 'PublicDnsName': 'ec2-35-182-200-255.ca-central-1.compute.amazonaws.com', 'PublicIpAddress': '35.182.200.255', 'State': {'Code': 16, 'Name': 'running'}, 'StateTransitionReason': '', 'SubnetId': 'subnet-0eb26575', 'VpcId': 'vpc-89bc09e0', 'Architecture': 'x86_64', 'BlockDeviceMappings': [{'DeviceName': '/dev/sda1', 'Ebs': {'AttachTime': datetime.datetime(2018, 3, 12, 10, 30, 47, tzinfo=tzutc()), 'DeleteOnTermination': True, 'Status': 'attached', 'VolumeId': 'vol-0b51877595e063882'}}], 'ClientToken': '152085064685063311', 'EbsOptimized': False, 'EnaSupport': False, 'Hypervisor': 'xen', 'IamInstanceProfile': {'Arn': 'arn:aws:iam::971302066566:instance-profile/aviatrix-role-ec2', 'Id': 'AIPAI6VQ5VKT6BWKG27JI'}, 'NetworkInterfaces': [{'Association': {'IpOwnerId': 'amazon', 'PublicDnsName': 'ec2-35-182-200-255.ca-central-1.compute.amazonaws.com', 'PublicIp': '35.182.200.255'}, 'Attachment': {'AttachTime': datetime.datetime(2018, 3, 12, 10, 30, 47, tzinfo=tzutc()), 'AttachmentId': 'eni-attach-7340f19b', 'DeleteOnTermination': True, 'DeviceIndex': 0, 'Status': 'attached'}, 'Description': '', 'Groups': [{'GroupName': 'Aviatrix for Cloud Interconnect- Cloud Peering and VPN -BYOL--111517-AutogenByAWSMP-1', 'GroupId': 'sg-6f83b207'}], 'Ipv6Addresses': [], 'MacAddress': '06:93:cd:63:c2:7a', 'NetworkInterfaceId': 'eni-853410d0', 'OwnerId': '971302066566', 'PrivateDnsName': 'ip-172-31-2-170.ca-central-1.compute.internal', 'PrivateIpAddress': '172.31.2.170', 'PrivateIpAddresses': [{'Association': {'IpOwnerId': 'amazon', 'PublicDnsName': 'ec2-35-182-200-255.ca-central-1.compute.amazonaws.com', 'PublicIp': '35.182.200.255'}, 'Primary': True, 'PrivateDnsName': 'ip-172-31-2-170.ca-central-1.compute.internal', 'PrivateIpAddress': '172.31.2.170'}], 'SourceDestCheck': True, 'Status': 'in-use', 'SubnetId': 'subnet-0eb26575', 'VpcId': 'vpc-89bc09e0'}], 'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs', 'SecurityGroups': [{'GroupName': 'Aviatrix for Cloud Interconnect- Cloud Peering and VPN -BYOL--111517-AutogenByAWSMP-1', 'GroupId': 'sg-6f83b207'}], 'SourceDestCheck': True, 'Tags': [{'Key': 'Name', 'Value': 'UCC_manual'}], 'VirtualizationType': 'hvm'}], 'OwnerId': '971302066566', 'ReservationId': 'r-0dcbc8209770ca286'}], 'ResponseMetadata': {'RequestId': '0b510002-f64f-4841-be49-2bb9e475921a', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 18:59:43 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}

        logger.info("ENDED: Describe EC2 Instances\n")

        return response


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def describe_iam_instance_profile_associations(region="", instance_id="", param2="", param3="", param4="", param5="", param6=""):
    logger.info("\nSTART: Describe IAM Instance Profile Associations for Instance: " + instance_id + " in " + region)

    ec2_client   = boto3.client(service_name='ec2',
                                region_name=region,
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)
    ec2_resource = boto3.resource(
        service_name='ec2',
        region_name=region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

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

        logger.info("    Succeed")
        logger.info(response)  # logger.info(response)  -->>  {'IamInstanceProfileAssociations': [{'AssociationId': 'iip-assoc-0366ca256cba98d83', 'InstanceId': 'i-0805e7138f8e540e1', 'IamInstanceProfile': {'Arn': 'arn:aws:iam::971302066566:instance-profile/byol-AviatrixInstanceProfile-1IWGARA2GOKHJ', 'Id': 'AIPAJQF4LCA6NR6L2SOWG'}, 'State': 'associated'}], 'ResponseMetadata': {'RequestId': '747594ad-35a6-43ae-a850-445c9c9623c0', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 19:58:55 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}

        ##### Step 02: Get Association-ID between Profile-Instance and EC2 Instance
        association_id = response["IamInstanceProfileAssociations"][0]["AssociationId"]
        logger.info("    Association-ID between Profile-Instance and EC2 Instance: " + association_id)

        ##### Step 03: Get Profile-Instance ARN
        instance_profile_arn = response["IamInstanceProfileAssociations"][0]["IamInstanceProfile"]["Arn"]
        logger.info("    Instance Profile ARN                                    : " + instance_profile_arn)

        logger.info("ENDED: Describe IAM Instance Profile Associations for Instance: " + instance_id + " in " + region + "\n")

        return association_id, instance_profile_arn


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



#######################################################################################################################
############################################    Elastic IP (EIP)     ##################################################
#######################################################################################################################


def allocate_eip(region=""):
    logger.info("\nSTART: Allocate EIP")

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
        ##### Step 01: Allocate EIP
        response = ec2_client.allocate_address(
            Domain="standard",  # 'vpc' | 'standard',
            # Address='string',
            DryRun=False
        )

        ##### Step 02: Get EIP ID
        logger.info("    Succeed")
        eip_id = response["AllocationId"]
        eip = response["PublicIp"]
        logger.info("    EIP ID: " + eip_id)
        logger.info("    EIP   : " + eip)

        logger.info("ENDED: Allocate EIP\n")

        return (eip_id, eip)


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def release_address(region="", eip_id=""):
    logger.info("\nSTART: Release EIP")

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
        ##### Step 01: Release EIP
        response = ec2_client.release_address(
            AllocationId=eip_id,
            # PublicIp=eip,
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Release EIP\n")

        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def associate_address(region="", eip="", instance_id=""):
    logger.info("\nSTART: Associate EIP to EC2 Instance")

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

        logger.info("    Succeed")
        eip_association_id = response["AssociationId"]
        logger.info("AssociationId: " + eip_association_id)
        logger.info("ENDED: Associate EIP to EC2 Instance\n")

        return eip_association_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



def disassociate_address(region="", eip_association_id=""):
    logger.info("\nSTART: Disassociate EIP from instance")

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
        ##### Step 01: Disassociate EIP from instance
        response = ec2_client.disassociate_address(
            AssociationId=eip_association_id,
            # PublicIp='string',
            DryRun=False
        )

        logger.info("    Succeed")
        logger.info("ENDED: Disassociate EIP from instance\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass




def describe_addresses(region="", param1="", param2="", param3="", param4="", param5="", param6=""):
    logger.info("\nSTART: Describe EIPs")

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

        logger.info("    Succeed")
        logger.info(response)  # logger.info(response)  -->>  {'Addresses': [{'InstanceId': 'i-0805e7138f8e540e1', 'PublicIp': '35.182.94.13', 'AllocationId': 'eipalloc-6f133641', 'AssociationId': 'eipassoc-ccebf406', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-9085a1c5', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.7.96'}, {'InstanceId': 'i-0ac9916bd87167dff', 'PublicIp': '52.60.65.87', 'AllocationId': 'eipalloc-1d301533', 'AssociationId': 'eipassoc-c8243b02', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-4d341018', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.3.205', 'Tags': [{'Key': 'Description', 'Value': 'Created by Aviatrix gateway gw1, please do NOT remove it.'}, {'Key': 'Name', 'Value': 'Aviatrix-eip@gw1-52.60.65.87'}]}], 'ResponseMetadata': {'RequestId': '8fcf2bb5-f44a-4645-9d5f-4c891ac2a826', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 21:29:52 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}
        logger.info("ENDED: Describe EIPs\n")

        return response


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass



"""
Check if an EC2 Instance is using EIP or not
"""
def is_instance_attached_eip(region="", instance_id=""):
    # logger.info("\nSTART: Check if an EC2 Instance is using EIP")

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
        # logger.info(response)  # -->>  {'Addresses': [{'InstanceId': 'i-0805e7138f8e540e1', 'PublicIp': '35.182.94.13', 'AllocationId': 'eipalloc-6f133641', 'AssociationId': 'eipassoc-ccebf406', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-9085a1c5', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.7.96'}, {'InstanceId': 'i-0ac9916bd87167dff', 'PublicIp': '52.60.65.87', 'AllocationId': 'eipalloc-1d301533', 'AssociationId': 'eipassoc-c8243b02', 'Domain': 'vpc', 'NetworkInterfaceId': 'eni-4d341018', 'NetworkInterfaceOwnerId': '971302066566', 'PrivateIpAddress': '172.31.3.205', 'Tags': [{'Key': 'Description', 'Value': 'Created by Aviatrix gateway gw1, please do NOT remove it.'}, {'Key': 'Name', 'Value': 'Aviatrix-eip@gw1-52.60.65.87'}]}], 'ResponseMetadata': {'RequestId': '8fcf2bb5-f44a-4645-9d5f-4c891ac2a826', 'HTTPStatusCode': 200, 'HTTPHeaders': {'content-type': 'text/xml;charset=UTF-8', 'transfer-encoding': 'chunked', 'vary': 'Accept-Encoding', 'date': 'Mon, 12 Mar 2018 21:29:52 GMT', 'server': 'AmazonEC2'}, 'RetryAttempts': 0}}
        eips = response["Addresses"]
        found = False

        # Iterate through all EIPs
        for i in range(len(eips)):
            instance_id = eips[i]["InstanceId"]
            if instance_id == instance_id:
                found = True
                break

        # logger.info("ENDED: Check if an EC2 Instance is using EIP\n")

        return found


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        pass

