#!/usr/bin/python3
# -*- coding: UTF-8 -*-


import os
import logging
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

def XXXXX_do_something_XXXXX(logger=None, 
                             region="", 
                             param1="", 
                             param2="", 
                             param3="",
                             aws_access_key_id="",
                             aws_secret_access_key=""
                             ):
    print("\nSTART: XXXXX_do_something_XXXXX")

    ec2_client   = boto3.client(service_name='ec2', 
                                region_name=region, 
                                aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key)

    ec2_resource = boto3.resource(service_name='ec2', 
                                  region_name=region,
                                  aws_access_key_id=aws_access_key_id,
                                  aws_secret_access_key=aws_secret_access_key)

    try:
        ##### Step 01: XXXXX_do_something_XXXXX
        response = ec2_client.XXXXX_AWS_API_CALL_XXXXX(
            param1=param1,
            param2=param2,
            DryRun=False
        )

        ##### Step 02: Get XXXXX_somthing_XXXXX
        print("    Succeed")
        print(response)  ########################################################################################################
        object_id = response["Object"]["ObjectId"]
        print("    XXXXX_something_XXXXX: " + object_id)


        print("ENDED: XXXXX_do_something_XXXXX\n")

        return object_id


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger(tracekback_msg)

    finally:
        return False

