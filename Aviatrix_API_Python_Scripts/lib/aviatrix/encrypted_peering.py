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
#########################################    Encrypted Peering    #####################################################
#######################################################################################################################

def create_encrypted_peering(
        logger=None,
        url=None,
        CID=None,
        gateway_name_1=None,
        gateway_name_2=None,
        ha_enabled=None,
        max_retry=10
        ):

    ### Required parameters
    data = {
        "action": "peer_vpc_pair",
        "CID": CID,
        "vpc_name1": gateway_name_1,
        "vpc_name2": gateway_name_2
    }

    ### Optional parameters
    if ha_enabled is not None:
        data["ha_enabled"] = ha_enabled

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



def delete_encrypted_peering(
        logger=None,
        url=None,
        CID=None,
        gateway_name_1=None,
        gateway_name_2=None,
        max_retry=10
        ):
    ### Required parameters
    data = {
        "action": "unpeer_vpc_pair",
        "CID": CID,
        "vpc_name1": gateway_name_1,
        "vpc_name2": gateway_name_2
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


