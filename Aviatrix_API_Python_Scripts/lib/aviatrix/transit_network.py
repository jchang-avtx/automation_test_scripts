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


#######################################################################################################################
#########################################    Transit Network    #######################################################
#######################################################################################################################

def list_transit_gw_supported_sizes(logger=None, url=None, CID=None):
    """
    This function invokes Aviatrix API "list_transit_gw_supported_sizes" and return a list of sizes (string)
    """
    sizes = list()
    params = {
        "action": "list_transit_gw_supported_sizes",
        "CID": CID
    }

    response = requests.get(url=url, params=params, verify=False)
    return response



def create_transit_gw(logger=None, url=None, CID=None, account_name=None, cloud_type=None, region=None, vpc_id=None,
                      public_subnet=None, gateway_name=None, gateway_size=None, dns_server_ip=None, tags=None):
    data = {
        "action": "create_transit_gw",
        "CID": CID,
        "account_name": account_name,
        "cloud_type": cloud_type,
        "region": region,
        "vpc_id": vpc_id,
        "public_subnet": public_subnet,
        "gw_name": gateway_name,
        "gw_size": gateway_size
    }

    if dns_server_ip is not None:
        data["dns_server"] = dns_server_ip
    if tags is not None:
        data["tags"] = tags

    response = requests.post(url=url, data=data, verify=False)
    return response



def enable_transit_ha(logger=None, url=None, CID=None, gateway_name=None, public_subnet=None, new_zone=None):
    """
    :param new_zone: This field is for GCloud ONLY
    """
    data = {
        "action": "enable_transit_ha",
        "CID": CID,
        "gw_name": gateway_name,
        "public_subnet": public_subnet
    }

    if new_zone is not None:
        data["new_zone"] = new_zone

    response = requests.post(url=url, data=data, verify=False)
    return response



def connect_transit_gw_to_vgw(logger=None, url=None, CID=None, connection_name=None,
                              transit_vpc_id=None, transit_gateway_name=None, bgp_local_as_number=None,
                              vgw_account_name=None, vgw_region=None, vgw_id=None):
    data = {
        "action": "connect_transit_gw_to_vgw",
        "CID": CID,
        "connection_name": connection_name,
        "vpc_id": transit_vpc_id,
        "transit_gw": transit_gateway_name,
        "bgp_local_as_number": bgp_local_as_number,
        "bgp_vgw_account_name": vgw_account_name,
        "bgp_vgw_region": vgw_region,
        "vgw_id": vgw_id
    }

    response = requests.post(logger=None, url=url, data=data, verify=False)
    return response



def create_spoke_gw(logger=None, url=None, CID=None, account_name=None, cloud_type=None, region=None, vpc_id=None,
                    public_subnet=None, gateway_name=None, gateway_size=None,
                    nat_enabled=None, dns_server_ip=None, tags=None):
    data = {
        "action": "create_spoke_gw",
        "CID": CID,
        "account_name": account_name,
        "cloud_type": cloud_type,
        "region": region,
        "vpc_id": vpc_id,
        "public_subnet": public_subnet,
        "gw_name": gateway_name,
        "gw_size": gateway_size
    }

    if nat_enabled is not None:
        data["nat_enabled"] = nat_enabled
    if dns_server_ip is not None:
        data["dns_server"] = dns_server_ip
    if tags is not None:
        data["tags"] = tags

    response = requests.post(url=url, data=data, verify=False)
    return response



def enable_spoke_ha(logger=None, url=None, CID=None, gateway_name=None, public_subnet=None, new_zone=None):
    """
    :param new_zone: This field is for GCloud ONLY
    """
    data = {
        "action": "enable_spoke_ha",
        "CID": CID,
        "gw_name": gateway_name,
        "public_subnet": public_subnet
    }

    if new_zone is not None:
        data["new_zone"] = new_zone

    response = requests.post(url=url, data=data, verify=False)
    return response



def attach_spoke_to_transit_gw(logger=None, url=None, CID=None, spoke_gateway=None, transit_gateway=None):
    data = {
        "action": "attach_spoke_to_transit_gw",
        "CID": CID,
        "spoke_gw": spoke_gateway,
        "transit_gw": transit_gateway
    }

    response = requests.post(url=url, data=data, verify=False)
    return response



def detach_spoke_from_transit_gw(logger=None, url=None, CID=None, spoke_gateway_name=None):
    data = {
        "action": "detach_spoke_from_transit_gw",
        "CID": CID,
        "spoke_gw": spoke_gateway_name
    }

    response = requests.post(url=url, data=data, verify=False)
    return response



def disconnect_transit_gw_from_vgw(logger=None, url=None, CID=None, connection_name=None, transit_vpc_id=None):
    data = {
        "action": "disconnect_transit_gw_from_vgw",
        "CID": CID,
        "connection_name": connection_name,
        "vpc_id": transit_vpc_id
    }

    response = requests.post(url=url, data=data, verify=False)
    return response



def delete_gateway(logger=None, url=None, CID=None, cloud_type=None, gateway_name=None):
    data = {
        "action": "delete_container",
        "CID": CID,
        "cloud_type": cloud_type,
        "gw_name": gateway_name
    }
    response = requests.post(url=url, data=data, verify=False)
    return response


