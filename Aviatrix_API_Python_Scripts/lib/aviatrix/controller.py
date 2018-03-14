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
###########################################    Controller    ##########################################################
#######################################################################################################################

def get_controller_version(logger=None, url=None, CID=None):
    params = {
        "action": "list_version_info",
        "CID": CID
    }
    response = requests.get(url=url, params=params, verify=False)
    return response



