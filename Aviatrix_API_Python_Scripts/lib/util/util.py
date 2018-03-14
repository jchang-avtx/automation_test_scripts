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
import winsound
import wmi

from urllib3.exceptions import NewConnectionError
from urllib3.exceptions import MaxRetryError
from requests.exceptions import ConnectionError

from lib.aviatrix.initial_setup import login
from lib.aviatrix.initial_setup import login_GET_method
from lib.aviatrix.controller import get_controller_version


#######################################################################################################################
#########################################    General     ##########################################################
#######################################################################################################################

def set_logger(logger_name="main",
               logging_level=logging.INFO,
               log_file_enabled=True,
               path_to_log_file=".result/log_history.txt",
               log_file_mode="a"
               ):
    ### Step 01: Create logger object
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.INFO)

    ### Step 02 : Setup format for log output
    formatter = logging.Formatter(
        "%(asctime)s    %(filename)s    [line:%(lineno)d]    %(levelname)s    %(message)s")

    ### Step 03 : Create a StreamHandler, for to writing output to stdout
    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(logging_level)

    ### Step 04: Add Formatter to StreamHandler
    stream_handler.setFormatter(formatter)

    if log_file_enabled:
        ### Step xx : Create a FileHandler, for writing output to a txt file
        file_handler = logging.FileHandler(filename=path_to_log_file, mode=log_file_mode, encoding="utf-8")
        file_handler.setLevel(logging_level)

        ### Step xx: Add Formatter to StreamHandler
        file_handler.setFormatter(formatter)
    ### END if

    ### Step FINAL: Add 2 Handlers to logger
    if log_file_enabled:
        logger.addHandler(file_handler)
    ### END if

    logger.addHandler(stream_handler)

    return logger



def delete_local_file(path_to_file):
    """
    This function deletes a local file.

    :param path_to_file:
    :return:
    """
    os.remove(path_to_file)
    return



def print_greeting_msg():
    print("\nWelcome to Aviatrix Transit-Network API with Python!")
    print("Aviatrix  --> Encrypted Tunnel  --> ∧v!@+r!x")
    print("✈ ☁ ✈ Aviatrix ✈ ☁ ✈ The Best Cloud Network Architect!! ✈ ☁ ✈ Aviatrix ✈ ☁ ✈")
    return



def print_farewell_msg():
    print("\nThank you for using Aviatrix!")
    print("Aviatrix  --> Encrypted Tunnel  --> ∧v!@+r!x")
    print("✈ ☁ ✈ Aviatrix ✈ ☁ ✈ The Best Cloud Network Architect!! ✈ ☁ ✈ Aviatrix ✈ ☁ ✈")
    return



def read_config_file_to_py_dict(path_to_file):
    print("\nSTART: Read configuration file and convert to Python dictionary")
    with open(path_to_file, "r") as in_file_stream:
        py_dict = json.load(in_file_stream)
        print("    Succeed")
        print("ENDED: Read configuration file and convert to Python dictionary\n")
        return py_dict



def write_py_dict_to_config_file(py_dict=None, path_to_file=None):
    print("\nSTART: Write Python dictionary to configuration file")
    with open(path_to_file, "w") as out_file_stream:
        json.dump(py_dict, out_file_stream)
        print("    Succeed")
        print("ENDED: Write Python dictionary to configuration file\n")
        return True



def check_requirements(config):
        print("\nSTART: Check requirements")
        ##### Check controller login
        print("    Checking Aviatrix controller accessibility... ")

        ### Login and Get CID
        controller_ip = config["controller"]["public_ip"]
        url = "https://" + controller_ip + "/v1/api"
        admin_password = config["controller"]["admin_password"]
        CID = login(url=url, username="admin", password=admin_password)

        print("        PASS: Successfully logged onto controller!")

        ### Check controller version
        print("    Checking Aviatrix controller version... ")

        # Get controller current version
        versions = ["UserConnect-3.1", "UserConnect-3.2", "UserConnect-3.3"]
        res_dict = get_controller_version(url=url, CID=CID)
        current_version = res_dict["result"]["current_version"]
        is_valid = False

        # Check version list
        for version in versions:
            if version in current_version:
                is_valid = True

        if is_valid:
            print("        PASS: Good! controller version is: " + current_version)
        else:
            print("        Fail: Current controller version is: " + current_version)
            print("        Please upgrade controller to the version that supports Transit Network Solution.")
            os.system("pause")

        ### Check cloud-account
        pass

        print("ENDED: Check requirements\n")
        return True



"""
For Windows
"""
def run_completion_notification():
    winsound.Beep(200, 100)
    winsound.Beep(300, 200)

    brightness = 50  # Vaild Value: 0 ~ 100
    wmi.WMI(namespace='wmi').WmiMonitorBrightnessMethods()[0].WmiSetBrightness(brightness, 0)
    time.sleep(0.25)
    wmi.WMI(namespace='wmi').WmiMonitorBrightnessMethods()[0].WmiSetBrightness(100, 0)
    return



def print_wall_beg():
    print("\n\n✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁")
    print("✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁\n")
    return



def print_wall_end():
    print("\n✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁\n\n")
    print("✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁\n")
    return



def print_exception_wall_beg():
    print("\n\n✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁\n")
    print("START: Exception/Error occurred, printing detail message...\n\n")
    return



def print_exception_wall_end():
    print("\n\nENDED: Exception/Error occurred, printing detail message...")
    print("\n✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁\n\n")

    return

