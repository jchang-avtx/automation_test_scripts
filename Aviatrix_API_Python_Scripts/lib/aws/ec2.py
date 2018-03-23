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


'''
from lib.aws.account import *
from lib.aws.iam import *
from lib.util.util import *

'''
import sys
sys.path.append('../util')
from apirequest import APIRequest



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
        ##### Step 01: Detach IGW from VPC
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

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create a rule for Security Group\n")




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
                 iam_instance_profile_name="",
                 iam_instance_profile_arn="",
                 network_interface_id="",
                 aws_access_key_id="",
                 aws_secret_access_key="",
                 log_indentation=""
                 ):
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

        ##### Step 02: Get Instance ID
        instance_id         = response["Instances"][0]["InstanceId"]
        instance_private_ip = response["Instances"][0]["PrivateIpAddress"]
        logger.info(log_indentation + "    Instance ID: " + instance_id)


        return instance_id, instance_private_ip

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create EC2 Instance/VM\n")




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
                   cfg_file=False):
    logger = logging.getLogger(__name__)
    vpc_cfg = {}
    ec2 = boto3.resource('ec2', 
                         aws_access_key_id=aws_access_key_id,
                         aws_secret_access_key=aws_secret_access_key,
                         region_name = region_name)
                         
    # create VPC
    vpc = ec2.create_vpc(CidrBlock=vpc_cidr)
    # we can assign a name to vpc, or any resource, by using tag
    vpc.create_tags(Tags=[{"Key": "Name", "Value": vpc_name_tag}])
    vpc.wait_until_available()
    print(vpc.id)
    vpc_cfg["vpc_name_tag"] = vpc_name_tag
    vpc_cfg["vpc_cidr"] = vpc_cidr
    vpc_cfg["vpc_id"] = vpc.id
    vpc_cfg["vpc_region"] = region_name

    # create then attach internet gateway
    ig = ec2.create_internet_gateway()
    vpc.attach_internet_gateway(InternetGatewayId=ig.id)
    print(ig.id)
    vpc_cfg["igw_id"] = ig.id

    # create a route table and a public route
    route_table = vpc.create_route_table()
    route = route_table.create_route(
        DestinationCidrBlock='0.0.0.0/0',
        GatewayId=ig.id
        )
    print(route_table.id)
    vpc_cfg["rtb_id"] = route_table.id

    # create subnet
    subnet_name = vpc_name_tag + '-public'
    subnet = ec2.create_subnet(CidrBlock=subnet_cidr, VpcId=vpc.id)
    subnet.create_tags(Tags=[{"Key": "Name", "Value": subnet_name}])
    print(subnet.id)
    vpc_cfg["subnet_name"] = subnet_name
    vpc_cfg["subnet_id"] = subnet.id
    vpc_cfg["subnet_cidr"] = subnet_cidr

    # associate the route table with the subnet
    route_table.associate_with_subnet(SubnetId=subnet.id)

    # Create sec group
    sg_name = vpc_name_tag + '-sg'
    sec_group = ec2.create_security_group(
       GroupName=sg_name, Description=sg_name, VpcId=vpc.id)
    sec_group.authorize_ingress(
        CidrIp='0.0.0.0/0',
        IpProtocol='icmp',
        FromPort=-1,
        ToPort=-1
    )
    sec_group.authorize_ingress(
        CidrIp='0.0.0.0/0',
        IpProtocol='tcp',
        FromPort=22,
        ToPort=22
    )
    print(sec_group.id)
    vpc_cfg["sg_name"] = sg_name
    vpc_cfg["sg_id"] = sec_group.id

    if create_instance:
        
        # Create ssh key
        key_pair_name = vpc_name_tag + '-sshkey'
        key_file_name = './config/' + key_pair_name + '.pem'
        private_key = create_key_pair(logger = logger,
                                      region=region_name,
                                      key_pair_name=key_pair_name,
                                      aws_access_key_id=aws_access_key_id,
                                      aws_secret_access_key=aws_secret_access_key) 
        print private_key
        try:
            with open(key_file_name, 'w+') as f:
                f.write(private_key)
        except Exception as e:
            print str(e)

        # Aquire AMI ID
        path_to_aws_global_config_file = '../../config_global/aws_config.json'
        with open(path_to_aws_global_config_file, 'r') as f:
            aws_config  = json.load(f)
        ami_id = aws_config["AWS"]["AMI"][region_name]["ubuntu_16_04"]
       
        # Create instance
        instances = ec2.create_instances(
            KeyName=key_pair_name, ImageId='ami-66506c1c', InstanceType='t2.micro', MaxCount=1, MinCount=1,
            NetworkInterfaces=[{'SubnetId': subnet.id, 'DeviceIndex': 0, 'AssociatePublicIpAddress': True, 'Groups': [sec_group.group_id]}])
        instances[0].wait_until_running()
        instances[0].load()
        print(instances[0].id)
        print(instances[0].public_ip_address)
        vpc_cfg["inst_id"] = instances[0].id
        vpc_cfg["inst_public_ip"] = instances[0].public_ip_address
    if cfg_file:
        cfg_file_path = './config/' + vpc_name_tag + '.cfg'
        with open(cfg_file_path, 'w+') as f:
            f.write(json.dumps(vpc_cfg, indent=2))


def aws_delete_vpc(aws_access_key_id=None,
                   aws_secret_access_key=None,
                   region_name=None,
                   vpc_name_tag = None,
                   vpc_id = None):

    logger = logging.getLogger(__name__)

    ec2 = boto3.resource('ec2',
                         aws_access_key_id=aws_access_key_id,
                         aws_secret_access_key=aws_secret_access_key,
                         region_name=region_name)
    ec2_client = ec2.meta.client

    vpc = ec2.Vpc(vpc_id)

    # delete any instances
    for subnet in vpc.subnets.all():
        for instance in subnet.instances.all():
            print 'terminate instance'
            instance.terminate()

    # delete all route table associations
    for rt in vpc.route_tables.all():
        for rta in rt.associations:
            if not rta.main:
                print rt.id
                rta.delete()
                ec2_client.delete_route_table(RouteTableId=rt.id)


    #sleep for dependency cleanup
    time.sleep(60)
    # delete network interfaces
    for subnet in vpc.subnets.all():
        print 'delete subnet'
        subnet.delete()

    # delete our security groups
    for sg in vpc.security_groups.all():
        if sg.group_name != 'default':
            print 'delete sg'
            sg.delete()

    time.sleep(60)
    # detach and delete all gateways associated with the vpc
    for gw in vpc.internet_gateways.all():
        print gw.id
        vpc.detach_internet_gateway(InternetGatewayId=gw.id)
        gw.delete()


    time.sleep(60)
    # finally, delete the vpc
    ec2_client.delete_vpc(VpcId=vpc_id)
    
    #delete key pair
    key_pair_name = vpc_name_tag + '-sshkey'
    ec2_client.delete_key_pair(
            KeyName=key_pair_name,
            DryRun=False
        )
    


