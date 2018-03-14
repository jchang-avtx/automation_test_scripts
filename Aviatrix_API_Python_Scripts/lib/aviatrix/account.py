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

from lib.aviatrix.initial_setup import get_cloud_type


#######################################################################################################################
###########################################    Cloud Account    #############################################################
#######################################################################################################################



def create_cloud_account(logger=None, base_url=None, CID=None,
                         account_name=None, account_password=None, account_email=None, cloud_type=None,
                         aws_account_number=None, iam_role_based="true",
                         aws_access_key_id=None, aws_secret_access_key=None,
                         aws_role_app_arn=None, aws_role_ec2_arn=None,
                         gce_project_id=None, gce_project_credential_file_abs_path_in_controller=None,
                         arm_subscription_id=None, arm_application_endpoint=None,
                         arm_application_client_id=None, arm_application_client_secret=None):
    cloud_type = get_cloud_type(cloud_type)
    data = {
        "action": "setup_account_profile",
        "account_name": account_name,
        "account_password": account_password,
        "account_email": account_email,
        "cloud_type": cloud_type,
        "CID": CID
    }

    if cloud_type == 1:  # AWS
        data["aws_account_number"] = aws_account_number
        if iam_role_based == "true":  # AWS-IAM-Role-based
            data["aws_iam"] = iam_role_based
            data["aws_role_arn"] = aws_role_app_arn
            data["aws_role_ec2"] = aws_role_ec2_arn
        elif iam_role_based == "false":  # AWS-keys
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

    response = requests.post(url=base_url, data=data, verify=False)

    return response

