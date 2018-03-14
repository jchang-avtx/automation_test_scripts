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
import winsound
import wmi

from urllib3.exceptions import NewConnectionError
from urllib3.exceptions import MaxRetryError
from requests.exceptions import ConnectionError

from lib.aviatrix.aviatrix_util import *
from lib.aviatrix.account import *
from lib.aviatrix.initial_setup import *
from lib.aviatrix.gateway import *
from lib.aviatrix.transit_network import *
from lib.aviatrix.transit_network import *

from lib.aws.account import *
from lib.aws.ec2 import *
from lib.aws.iam import *

from lib.util.util import *


#######################################################################################################################
#################################################    Category     #######################################################
#######################################################################################################################

def create_XXXXXXXXXX_api(logger=None, url=None, CID=None, param1=None, param2=None, param3=None, param4=None):


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

    # Send the GET/POST RESTful API request
    response = requests.get(base_url, params=payload, verify=False)
    OR
    response = requests.post(base_url, data=payload, verify=False)

    return response

