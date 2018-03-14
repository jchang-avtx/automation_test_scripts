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
############################################    Account     ##########################################################
#######################################################################################################################
logger=None,
, aws_access_key_id="", aws_secret_access_key=""):

,
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key
    ):

logger.info
logger.error


def get_aws_account_id(logger=None, aws_access_key_id="", aws_secret_access_key=""):
    logger.info("\nSTART: Get AWS Account ID")

    sts_client = boto3.client(
        "sts",
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Get AWS Account ID
        aws_account_id = sts_client.get_caller_identity()["Account"]
        logger.info("    Succeed")
        logger.info("ENDED: Get AWS Account ID\n")

        return aws_account_id

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    finally:
        return False

