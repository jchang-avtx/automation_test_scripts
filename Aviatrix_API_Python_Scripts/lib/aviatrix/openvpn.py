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
###############################################    VPN Users     ######################################################
#######################################################################################################################



def create_vpn_user(
        logger=None,
        url=None,
        CID=None,
        vpc_id=None,
        username=None,
        lb_name=None,
        gateway_name=None,
        user_email=None,
        profile_name=None,
        max_retry=10,
        log_indentation=""
        ):
    if lb_name is not None:
        lb_or_gateway_name = lb_name
    else:
        lb_or_gateway_name = gateway_name

    ### Required parameters
    data = {
        "action": "add_vpn_user",
        "CID": CID,
        "vpc_id": vpc_id,
        "username": username,
        "lb_name": lb_or_gateway_name
    }

    ### Optional parameters
    if user_email is not None:
        data["user_email"] = user_email
    if profile_name is not None:
        data["profile_name"] = profile_name

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





def delete_vpn_user(
        logger=None,
        url=None,
        CID=None,
        vpc_id=None,
        username=None,
        max_retry=10,
        log_indentation=""
        ):
    ### Required parameters
    data = {
        "action": "delete_vpn_user",
        "CID": CID,
        "vpc_id": vpc_id,
        "username": username
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


