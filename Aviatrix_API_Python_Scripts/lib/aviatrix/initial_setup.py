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
#########################################    Initial Setup    #########################################################
#######################################################################################################################

def get_server_status_code(logger=None, url=None):
    logger.info("START: Get Server Status Code")

    try:
        response = requests.get(url=url, verify=False, timeout=5)
        status_code = response.status_code
        return status_code

    except TimeoutError as e:
        logger.error("    Server Time out...")

    except Exception as e:
        logger.info("    Waiting for server...")

    finally:
        logger.info("ENDED: Get Server Status Code")



def login_GET_method(logger=None, url=None, username=None, password=None, max_retry=10):
    """
    This function logs user onto the Aviatrix controller and return CID (session)
    :param url: "https"//CONTROLLER_IP/v1/api
    :param username: Aviatrix-Cloud-Account username
    :param password: password
    :return: CID
    """
    try:
        params = {
            "action": "login",
            "username": username,
            "password": password
        }

        ### Call Aviatrix API (with max retry)
        for i in range(max_retry):
            try:
                # Send the GET/POST RESTful API request
                response = requests.get(url=url, params=params, verify=False)

                if response.status_code == 200:
                    # IF status_code is 200 meaning server has responded, then break out of retry loop
                    break

            except Exception as e:
                tracekback_msg = traceback.format_exc()
                logger.error(tracekback_msg)
                # END try-except
        # END for
        return response

    except ConnectionRefusedError as e:
        logger.info("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except NewConnectionError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except MaxRetryError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except ConnectionError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)



def login(logger=None, url=None, username=None, password=None, max_retry=10):
    """
    This function logs user onto the Aviatrix controller and return CID (session)
    :param url: "https"//CONTROLLER_IP/v1/api
    :param username: Aviatrix-Cloud-Account username
    :param password: password
    :return: CID
    """
    try:
        data = {
            "action": "login",
            "username": username,
            "password": password
        }

        ### Call Aviatrix API (with max retry)
        for i in range(max_retry):
            try:
                # Send the GET/POST RESTful API request
                response = requests.post(url=url, data=data, verify=False)

                if response.status_code == 200:
                    # IF status_code is 200 meaning server has responded, then break out of retry loop
                    break

            except Exception as e:
                tracekback_msg = traceback.format_exc()
                logger.error(tracekback_msg)
                # END try-except
        # END for
        return response

    except ConnectionRefusedError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except NewConnectionError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except MaxRetryError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except ConnectionError as e:
        logger.error("Looks like controller apache service is not ready yet. Lets wait for a bit...")
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.error(tracekback_msg)



def set_admin_email(logger=None, url=None, CID=None, admin_email=None, max_retry=10):
    data = {
        "action": "add_admin_email_addr",
        "admin_email": admin_email,
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def set_admin_email_GET(logger=None, url=None, CID=None, admin_email=None, max_retry=10):
    params = {
        "action": "add_admin_email_addr",
        "admin_email": admin_email,
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=params, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def change_password(logger=None, url=None, CID=None, username=None, password=None, new_password=None, max_retry=10):
    data = {
        "action": "edit_account_user",
        "username": username,
        "what": "password",
        "old_password": password,
        "new_password": new_password,
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def change_password_2_6_GET(logger=None,
                            url=None,
                            CID=None,
                            account_name=None,
                            username=None,
                            password=None,
                            new_password=None,
                            max_retry=10):
    params = {
        "action": "change_password",
        "account_name": account_name,
        "user_name": username,
        "old_password": password,
        "password": new_password,
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=params, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def run_initial_setup(logger=None, url=None, CID=None, max_retry=10):
    data = {
        "action": "initial_setup",
        "subaction": "run",
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def set_customer_id(logger=None, url=None, CID=None, customer_id=None, max_retry=10):
    data = {
        "action": "setup_customer_id",
        "customer_id": customer_id,
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def set_customer_id_GET(logger=None, url=None, CID=None, customer_id=None, max_retry=10):
    params = {
        "action": "setup_customer_id",
        "customer_id": customer_id,
        "CID": CID
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=params, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
            # END try-except
    # END for
    return response



def get_cloud_type(logger=None, cloud_type="", log_indentation=""):
    logger.info(log_indentation +
                "START: Input cloud vendor name in String and convert to Integer for Aviatrix cloud type mapping.")
    cloud_type = cloud_type.lower()

    try:
        if cloud_type == "aws" or cloud_type == "amazon":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 1")
            return 1
        elif cloud_type == "azure" or cloud_type == "azure_classic":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 2")
            return 2
        elif cloud_type == "google" or cloud_type == "gcloud" or cloud_type == "gcp" or cloud_type == "gce":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 4")
            return 4
        elif cloud_type == "arm" or cloud_type == "azure_arm":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 8")
            return 8
        elif cloud_type == "aws_gov":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 256")
            return 256
        elif cloud_type == "azure_china":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 512")
            return 512
        elif cloud_type == "aws_china":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 1024")
            return 1024
        elif cloud_type == "arm_china" or cloud_type == "azure_arm_china":
            logger.info(log_indentation + "The corresponding INTEGER value for " + cloud_type + " is 2048")
            return 2048

        logger.error(log_indentation + "Invalid Cloud Type Value: " + str(cloud_type))
        return False

    finally:
        logger.info(log_indentation +
                    "ENDED: Input cloud vendor name in String and convert to "
                    "Integer for Aviatrix cloud type mapping.\n")


