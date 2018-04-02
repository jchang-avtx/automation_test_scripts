#!/usr/bin/python3
# -*- coding: UTF-8 -*-


import os
import traceback
import time
import datetime
import paramiko
import boto3
import json
import requests

from urllib3.exceptions import NewConnectionError
from urllib3.exceptions import MaxRetryError
from requests.exceptions import ConnectionError


requests.packages.urllib3.disable_warnings()


#######################################################################################################################
##############################################    Site2Cloud     ######################################################
#######################################################################################################################

def create_site2cloud(
        logger=None,
        url=None,
        CID=None,

        vpc_id=None,
        connection_name=None,
        connection_type=None,
        remote_gateway_type=None,
        tunnel_type=None,

        primary_gateway_name=None,
        remote_primary_gateway_ip=None,
        pre_shared_key=None,
        local_subnet_cidr=None,
        remote_subnet_cidr=None,

        ha_enabled="false",
        backup_gateway_name=None,
        remote_backup_gateway_ip=None,
        pre_shared_key_for_backup_connection=None,

        phase_1_auth=None,
        phase_1_dh_groups=None,
        phase_1_encryption=None,
        phase_2_auth=None,
        phase_2_dh_groups=None,
        phase_2_encryption=None,

        save_template="false",
        max_retry=10,
        log_indentation=""
        ):
    ### Required parameters
    data = {
        "action": "add_site2cloud",
        "CID": CID,
        "vpc_id": vpc_id,
        "name": connection_name,
        "conn_type": connection_type,
        "remote_gw_type": remote_gateway_type,
        "tunnel_type": tunnel_type,
        "gw_name": primary_gateway_name,
        "peer_ip": remote_primary_gateway_ip,
        "cloud_subnet": local_subnet_cidr,
        "remote_cidr": remote_subnet_cidr
    }

    ### Optional parameters
    if pre_shared_key is not None:
        data["presk"] = pre_shared_key

    if ha_enabled is not None:
        data["enable_ha"] = ha_enabled
    if backup_gateway_name is not None:
        data["gw_name2"] = backup_gateway_name
    if remote_backup_gateway_ip is not None:
        data["peer_ip2"] = remote_backup_gateway_ip
    if pre_shared_key_for_backup_connection is not None:
        data["presk2"] = pre_shared_key_for_backup_connection

    if phase_1_auth is not None:
        data["ph1_auth"] = phase_1_auth
    if phase_1_dh_groups is not None:
        data["ph1_dh"] = phase_1_dh_groups
    if phase_1_encryption is not None:
        data["ph1_encr"] = phase_1_encryption
    if phase_2_auth is not None:
        data["ph2_auth"] = phase_2_auth
    if phase_2_dh_groups is not None:
        data["ph2_dh"] = phase_2_dh_groups
    if phase_2_encryption is not None:
        data["ph2_encr"] = phase_2_encryption

    if save_template is not None:
        data["save_template"] = save_template

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

    # logger.info("END: Aviatrix API: " + api_name)
    return response
# END create_site2cloud()


def delete_site2cloud(
        logger=None,
        url=None,
        CID=None,
        vpc_id=None,
        connection_name=None,
        max_retry=10,
        log_indentation=""
        ):
    ### Required parameters
    data = {
        "action": "delete_site2cloud",
        "CID": CID,
        "vpc_id": vpc_id,
        "connection_name": connection_name
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

    # logger.info("END: Aviatrix API: " + api_name)
    return response
# END delete_site2cloud()

