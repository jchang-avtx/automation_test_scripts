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



#######################################################################################################################
############################################    Account     ##########################################################
#######################################################################################################################

def get_aws_account_id(logger=None, aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Get AWS Account ID Number")

    sts_client = boto3.client(
        "sts",
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:

        ##### Step 01: Get AWS Account ID
        logger.info(log_indentation + "    " + str(sts_client.get_caller_identity()))
        logger.info(log_indentation + "    Succeed")
        aws_account_id = sts_client.get_caller_identity()["Account"]
        logger.info(log_indentation + "    AWS ID Number is: " + str(aws_account_id))

        return aws_account_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Get AWS Account ID Number\n")


