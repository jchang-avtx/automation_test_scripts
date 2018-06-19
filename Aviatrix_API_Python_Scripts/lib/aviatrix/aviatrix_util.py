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


from lib.aws.account import get_aws_account_id


requests.packages.urllib3.disable_warnings()


#######################################################################################################################
#######################################    Aviatrix Util    ###########################################################
#######################################################################################################################

def get_aviatrix_aws_iam_policy(logger=None, url=None, log_indentation=""):
    logger.info(log_indentation + "START: Visit Aviatrix Website to get Aviatrix-AWS-IAM-Policy")

    try:
        response = requests.get(url=url)
        policy = response.text  # string type
        return policy

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Visit Aviatrix Website to get Aviatrix-AWS-IAM-Policy")



def download_aviatrix_aws_iam_policy(logger=None, url=None, save_to=None, log_indentation=""):
    logger.info(log_indentation + "START: Download/Save Aviatrix-AWS-IAM-Policy to a local file")

    policy = get_aviatrix_aws_iam_policy(logger=logger, url=url, log_indentation=log_indentation+"    ")  # return string
    logger.info(log_indentation + "Aviatrix Policy Body Content:")
    logger.info("\n" + str(policy))
    with open(save_to, "w", newline="") as output_file_stream:
        output_file_stream.write(policy)

    logger.info(log_indentation + "ENDED: Download/Save Aviatrix-AWS-IAM-Policy to a local file\n")
    return True



def read_aws_iam_role_document_to_string(logger=None,
                                         path_to_role_document="",
                                         is_app_role=False,
                                         aws_access_key_id="",
                                         aws_secret_access_key="",
                                         log_indentation=""
                                         ):
    logger.info(log_indentation + "START: Read AWS IAM Role-Policy-Document from local to string...")
    ### Step 01: Read the input file for Role Policy Document Content
    with open(path_to_role_document, "r") as input_file_stream:
        role_policy_doc = input_file_stream.read()

    if is_app_role:
        logger.info(log_indentation + "This is aviatrix-role-app. Therefore, it needs to get AWS Account ID Number...")
        ### Step 02: Get AWS Account ID Number
        aws_account_id = get_aws_account_id(logger=logger,
                                            aws_access_key_id=aws_access_key_id,
                                            aws_secret_access_key=aws_secret_access_key,
                                            log_indentation=log_indentation+"    "
                                            )

        ### Step 03: Fill AWS Account ID into the doc
        role_policy_doc = role_policy_doc.replace("MY_ACCOUNT_ID", aws_account_id)
    # END if
    logger.info(log_indentation + "    Role-Policy-Document is: \n" + role_policy_doc)
    logger.info(log_indentation + "ENDED: Read AWS IAM Role-Policy-Document from local to string...\n")
    return role_policy_doc
