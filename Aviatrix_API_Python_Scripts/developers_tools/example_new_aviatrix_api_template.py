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
#################################################    Category     #######################################################
#######################################################################################################################



def create_XXX_avx_object_XXX(
        logger=None,
        url=None,
        CID=None,
        param1=None,
        param2=None,
        optional_param3=None,
        optional_param4=None,
        max_retry=10,
        log_indentation=""
        ):

    ### Required parameters
    payload = {
        "action": "XXXXXXXXXX",
        "CID": CID,
        "param1": param1,
        "param2": param2,
        "param3": param3,
        "param4": param4,
    }


    ### Optional parameters
    if optional_arg3 is not None:
        payload["key3"] = optional_arg3
    if optional_arg4 is not None:
        payload["key4"] = optional_arg4


    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=params, verify=False)
            OR
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
# END create_XXX_avx_object_XXX()
