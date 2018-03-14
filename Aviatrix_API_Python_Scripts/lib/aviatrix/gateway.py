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
###########################################    Gateway    #############################################################
#######################################################################################################################


def list_public_subnets(logger=None, url=None, CID=None, account_name=None, cloud_type=None, region=None, vpc_id=None):
    """
    This function invokes Aviatrix API "list_public_subnets" and return a list of public subnet information (string)
    """
    public_subnets = list()
    params = {
        "action": "list_public_subnets",
        "CID": CID,
        "account_name": account_name,
        "cloud_type": cloud_type,
        "region": region,
        "vpc_id": vpc_id
    }

    response = requests.get(url=url, params=params, verify=False)
    return response



