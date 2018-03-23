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


requests.packages.urllib3.disable_warnings()


#######################################################################################################################
#########################################    Transit Network    #######################################################
#######################################################################################################################

def list_transit_gw_supported_sizes(logger=None, url=None, CID=None, max_retry=10):
    """
    This function invokes Aviatrix API "list_transit_gw_supported_sizes" and return a list of sizes (string)
    """
    sizes = list()
    params = {
        "action": "list_transit_gw_supported_sizes",
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=params, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def create_transit_gw(logger=None, url=None, CID=None,
                      account_name=None, cloud_type=None,
                      region=None, vpc_id=None, public_subnet=None,
                      gateway_name=None, gateway_size=None,
                      dns_server_ip=None, tags=None,
                      max_retry=10):
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

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def enable_transit_ha(logger=None,
                      url=None,
                      CID=None,
                      gateway_name=None,
                      public_subnet=None,
                      new_zone=None,
                      max_retry=10):
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

        ### Call Aviatrix API (with max retry)
        for i in range(max_retry):
            try:
                # Send the GET/POST RESTful API request
                response = requests.post(url=url, data=data, verify=False)

                if response.status_code == 200:
                    # IF status_code is 200 meaning server has responded, then break out of retry loop
                    break

            except Exception as e:
                tracekback_msg = traceback.format_exc()
                logger.error(tracekback_msg)
                # END try-except
        # END for
    return response



def connect_transit_gw_to_vgw(logger=None, url=None, CID=None, connection_name=None,
                              transit_vpc_id=None, transit_gateway_name=None, bgp_local_as_number=None,
                              vgw_account_name=None, vgw_region=None, vgw_id=None, max_retry=10):
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

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
            # END for
    return response



def create_spoke_gw(logger=None, url=None, CID=None, account_name=None, cloud_type=None, region=None, vpc_id=None,
                    public_subnet=None, gateway_name=None, gateway_size=None,
                    nat_enabled=None, dns_server_ip=None, tags=None, max_retry=10):
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

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def enable_spoke_ha(logger=None, url=None, CID=None, gateway_name=None, public_subnet=None, new_zone=None, max_retry=10):
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

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def attach_spoke_to_transit_gw(logger=None, url=None, CID=None, spoke_gateway=None, transit_gateway=None, max_retry=10):
    data = {
        "action": "attach_spoke_to_transit_gw",
        "CID": CID,
        "spoke_gw": spoke_gateway,
        "transit_gw": transit_gateway
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def detach_spoke_from_transit_gw(logger=None, url=None, CID=None, spoke_gateway_name=None, max_retry=10):
    data = {
        "action": "detach_spoke_from_transit_gw",
        "CID": CID,
        "spoke_gw": spoke_gateway_name
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def disconnect_transit_gw_from_vgw(logger=None,
                                   url=None,
                                   CID=None,
                                   connection_name=None,
                                   transit_vpc_id=None,
                                   max_retry=10):
    data = {
        "action": "disconnect_transit_gw_from_vgw",
        "CID": CID,
        "connection_name": connection_name,
        "vpc_id": transit_vpc_id
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def delete_gateway(logger=None, url=None, CID=None, cloud_type=None, gateway_name=None, max_retry=10):
    data = {
        "action": "delete_container",
        "CID": CID,
        "cloud_type": cloud_type,
        "gw_name": gateway_name
    }
    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response


