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

from lib.aws.account import get_aws_account_id


#######################################################################################################################
#######################################    Aviatrix Util    ###########################################################
#######################################################################################################################

def get_aviatrix_aws_iam_policy(logger=None, url=None):
    response = requests.get(url=url)
    policy = response.text  # string type
    return policy



def download_aviatrix_aws_iam_policy(logger=None, url=None, save_to=None):
    policy = get_aviatrix_aws_iam_policy(url=url)  # return string
    logger.info("\nAviatrix Policy Body Content:")
    logger.info("==================================================================================================\n")
    logger.info("\n" + policy + "\n")
    logger.info("==================================================================================================\n")
    with open(save_to, "w", newline="") as output_file_stream:
        output_file_stream.write(policy)

    return True



def read_aws_iam_role_document_to_string(logger=None, path_to_role_document="", is_app_role=False):
    ### Step 01: Read the input file for Role Policy Document Content
    with open(path_to_role_document, "r") as input_file_stream:
        role_policy_doc = input_file_stream.read()

    if is_app_role:
        ### Step 02: Get AWS Account ID Number
        aws_account_id = get_aws_account_id()

        ### Step 03: Fill AWS Account ID into the doc
        role_policy_doc = role_policy_doc.replace("MY_ACCOUNT_ID", aws_account_id)

    return role_policy_doc
