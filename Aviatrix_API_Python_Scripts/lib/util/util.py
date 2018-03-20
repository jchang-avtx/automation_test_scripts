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
        "%(asctime)s    %(filename)35s    [line:%(lineno)4d]    %(levelname)8s    %(message)s")

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



def delete_local_file(logger=None, path_to_file="", log_indentation=""):
    """
    This function deletes a local file.

    :param path_to_file:
    :return:
    """
    logger.info(log_indentation + "START: Delete local file")
    os.remove(path_to_file)
    logger.info(log_indentation + "ENDED: Delete local file")
    return True



def read_config_file_to_py_dict(logger=None, path_to_file="", log_indentation=""):
    ### This block of commented code is for debugging purpose only. To display the PATH to file
    # if logger is None:
    #     print("START: Read JSON format configuration file to string from PATH: " + path_to_file)
    # else:
    #     logger.info("START: Read JSON format configuration file to string from PATH: " + path_to_file)

    with open(path_to_file, "r") as in_file_stream:
        py_dict = json.load(in_file_stream)

        # if logger is None:
        #     print("ENDED: Read JSON format configuration file to string from PATH: " + path_to_file)
        # else:
        #     logger.info("ENDED: Read JSON format configuration file to string from PATH: " + path_to_file)

        return py_dict



def write_py_dict_to_config_file(logger=None, py_dict=None, path_to_file=None, log_indentation=""):
    # logger.info(log_indentation + "START: Write python-dict to JSON format configuration file PATH: " + path_to_file)

    with open(path_to_file, "w") as out_file_stream:
        json.dump(py_dict, out_file_stream)

        # logger.info(log_indentation + "ENDED: Write python-dict to JSON format configuration file PATH: " + path_to_file)
        return True



def check_requirements(logger=None, config=None, log_indentation=""):
        logger.info(log_indentation + "START: Check requirements")
        ##### Check controller login
        logger.info(log_indentation + "    Checking Aviatrix controller accessibility... ")

        ### Login and Get CID
        controller_ip = config["controller"]["public_ip"]
        url = "https://" + controller_ip + "/v1/api"
        admin_password = config["controller"]["admin_password"]
        CID = login(url=url, username="admin", password=admin_password)

        logger.info(log_indentation + "        PASS: Successfully logged onto controller!")

        ### Check controller version
        logger.info(log_indentation + "    Checking Aviatrix controller version... ")

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
            logger.info(log_indentation + "        PASS: Good! controller version is: " + current_version)
        else:
            logger.info(log_indentation + "        Fail: Current controller version is: " + current_version)
            logger.info(log_indentation +
                        "        Please upgrade controller to the version that supports Transit Network Solution.")
            os.system("pause")

        ### Check cloud-account
        pass

        logger.info(log_indentation + "ENDED: Check requirements\n")
        return True



"""
For Windows
"""
def run_completion_notification(logger=None, log_indentation=""):
    winsound.Beep(200, 100)
    winsound.Beep(300, 200)

    brightness = 50  # Vaild Value: 0 ~ 100
    wmi.WMI(namespace='wmi').WmiMonitorBrightnessMethods()[0].WmiSetBrightness(brightness, 0)
    time.sleep(0.25)
    wmi.WMI(namespace='wmi').WmiMonitorBrightnessMethods()[0].WmiSetBrightness(100, 0)
    return True



def print_wall_beg(logger=None):
    logger.info("WELCOME TO AVIATRIX!\n" +
                "✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁" +
                " ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈\n")
    return True



def print_wall_end(logger=None):
    logger.info("Thank You for Cloud Surfing with Aviatrix \n" +
                "✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁" +
                " ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈\n")
    return True



def print_greeting_msg(logger=None):
    logger.info("\nWelcome to Aviatrix Transit-Network API with Python!")
    logger.info("Aviatrix  --> Encrypted Tunnel  --> ∧v!@+r!x")
    logger.info("✈ ☁ ✈ Aviatrix ✈ ☁ ✈ The Best Cloud Network Architect!! ✈ ☁ ✈ Aviatrix ✈ ☁ ✈")
    return True



def print_farewell_msg(logger=None):
    logger.info("\nThank you for using Aviatrix!")
    logger.info("Aviatrix  --> Encrypted Tunnel  --> ∧v!@+r!x")
    logger.info("✈ ☁ ✈ Aviatrix ✈ ☁ ✈ The Best Cloud Network Architect!! ✈ ☁ ✈ Aviatrix ✈ ☁ ✈")
    return True



def print_exception_wall_beg(logger=None):
    logger.info("\n\n\n✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ \n")
    logger.info("START: Exception/Error occurred, printing detail message...\n\n")
    return True



def print_exception_wall_end(logger=None):
    logger.info("\n\nENDED: Exception/Error occurred, printing detail message...")
    logger.info("\n\n✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ ☁ ✈ \n\n")
    return True

