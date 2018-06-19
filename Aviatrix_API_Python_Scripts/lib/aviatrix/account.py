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
sys.path.append((PATH_TO_PROJECT_ROOT_DIR))


from lib.aviatrix.initial_setup import get_cloud_type


requests.packages.urllib3.disable_warnings()


#######################################################################################################################
###########################################    Cloud Account    #############################################################
#######################################################################################################################



def create_cloud_account(logger=None, url=None, CID=None,
                         account_name=None, account_password=None, account_email=None, cloud_type=None,
                         aws_account_number=None, iam_role_based=True,
                         aws_access_key_id=None, aws_secret_access_key=None,
                         aws_role_app_arn=None, aws_role_ec2_arn=None,
                         gce_project_id=None, gce_project_credential_file_abs_path_in_controller=None,
                         arm_subscription_id=None, arm_application_endpoint=None,
                         arm_application_client_id=None, arm_application_client_secret=None,
                         max_retry=10):
    ### Required parameters
    data = {
        "action": "setup_account_profile",
        "account_name": account_name,
        "account_password": account_password,
        "account_email": account_email,
        "cloud_type": cloud_type,
        "CID": CID
    }

    ### Optional parameters
    if cloud_type == 1:  # AWS
        data["aws_account_number"] = aws_account_number
        if iam_role_based:  # AWS-IAM-Role-based
            data["aws_iam"] = "true"
            data["aws_role_arn"] = aws_role_app_arn
            data["aws_role_ec2"] = aws_role_ec2_arn
        else:  # AWS-keys
            data["aws_iam"] = "false"
            data["aws_access_key"] = aws_access_key_id
            data["aws_secret_key"] = aws_secret_access_key
    elif cloud_type == "4":  # Google Cloud
        data["gcloud_project_name"] = gce_project_id
        data["gcloud_project_credentials"] = gce_project_credential_file_abs_path_in_controller
    elif cloud_type == "8":  # Azure ARM
        data["arm_subscription_id"] = arm_subscription_id
        data["arm_application_endpoint"] = arm_application_endpoint
        data["arm_application_client_id"] = arm_application_client_id
        data["arm_application_client_secret"] = arm_application_client_secret

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



def delete_cloud_account(
        logger=None,
        url=None,
        CID=None,
        account_name=None,
        max_retry=10
        ):
    ### Required parameters
    data = {
        "action": "delete_account_profile",
        "CID": CID,
        "account_name": account_name
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

