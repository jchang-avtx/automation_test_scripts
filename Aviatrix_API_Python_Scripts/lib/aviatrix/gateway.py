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

def list_public_subnets(logger=None,
                        url=None,
                        CID=None,
                        account_name=None,
                        cloud_type=None,
                        region=None,
                        vpc_id=None,
                        max_retry=10):
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

    # logger.info("END: Aviatrix API: " + api_name)
    return response



def create_gateway(logger=None, url=None, CID=None,
                   avx_cloud_account_name=None, cloud_type=None, vpc_region=None, vpc_id=None,
                   subnet_name=None, gateway_size=None, gateway_name=None,

                   allocate_new_eip="on", zone=None, enable_nat=None,
                   vpn_access="no", vpn_cidr=None, split_tunnel=None, max_connection=None, additional_cidrs=None,
                   enable_elb=None, elb_name=None,

                   otp_mode=None,
                   duo_integration_key=None, duo_secret_key=None, duo_api_hostname=None, duo_push_mode=None,
                   okta_url=None, okta_token=None, okta_username_suffix=None,

                   enable_client_cert_sharing=None, nameservers=None, search_domains=None,

                   enable_pbr=None, pbr_subnet=None, pbr_default_gateway=None, pbr_logging=None,

                   enable_ldap=None, ldap_server=None, ldap_bind_dn=None, ldap_password=None, ldap_base_dn_for_user_entry=None,
                   ldap_username_attribute=None, ldap_additional_req=None, ldap_use_ssl=None,
                   ldap_client_cert=None, ldap_ca_cert=None,

                   save_template="yes", max_retry=10):
    ### Required parameters
    data = {
        "action": "connect_container",
        "CID": CID,
        "account_name": avx_cloud_account_name,
        "cloud_type": cloud_type,
        "vpc_reg": vpc_region,
        "vpc_id": vpc_id,
        "vpc_net": subnet_name,
        "vpc_size": gateway_size,
        "gw_name": gateway_name
    }

    ### Optional parameters
    if allocate_new_eip is not None:
        data["allocate_new_eip"] = allocate_new_eip
    if zone is not None:
        data["zone"] = zone
    if enable_nat is not None:
        data["enable_nat"] = enable_nat

    if vpn_access is not None:
        data["vpn_access"] = vpn_access
    if vpn_cidr is not None:
        data["cidr"] = vpn_cidr
    if max_connection is not None:
        data["max_connection"] = max_connection
    if additional_cidrs is not None:
        data["additional_cidrs"] = additional_cidrs
    if split_tunnel is not None:
        data["split_tunnel"] = split_tunnel
    if enable_elb is not None:
        data["enable_elb"] = enable_elb

    if otp_mode is not None:  # otp stands for 2 Step Authentication. Valid Values: "2": DUO, "3": Okta
        data["otp_mode"] = otp_mode
    if duo_integration_key is not None:
        data["duo_integration_key"] = duo_integration_key
    if duo_secret_key is not None:
        data["duo_secret_key"] = duo_secret_key
    if duo_api_hostname is not None:
        data["duo_api_hostname"] = duo_api_hostname
    if duo_push_mode is not None:
        data["duo_push_mode"] = duo_push_mode  # Valid values: “auto”, “selective” and “token”
    if okta_url is not None:
        data["okta_url"] = okta_url
    if okta_token is not None:
        data["okta_token"] = okta_token
    if okta_username_suffix is not None:
        data["okta_username_suffix"] = okta_username_suffix

    if enable_client_cert_sharing is not None:
        data["enable_client_cert_sharing"] = enable_client_cert_sharing
    if nameservers is not None:
        data["nameservers"] = nameservers
    if search_domains is not None:
        data["search_domains"] = search_domains

    if enable_pbr is not None:
        data["enable_pbr"] = enable_pbr
    if pbr_subnet is not None:
        data["pbr_subnet"] = pbr_subnet
    if pbr_default_gateway is not None:
        data["pbr_default_gateway"] = pbr_default_gateway
    if pbr_logging is not None:
        data["pbr_logging"] = pbr_logging

    if enable_ldap is not None:
        data["enable_ldap"] = enable_ldap
    if ldap_server is not None:
        data["ldap_server"] = ldap_server
    if ldap_bind_dn is not None:
        data["ldap_bind_dn"] = ldap_bind_dn
    if ldap_password is not None:
        data["ldap_password"] = ldap_password
    if ldap_base_dn_for_user_entry is not None:
        data["ldap_base_dn"] = ldap_base_dn_for_user_entry
    if ldap_username_attribute is not None:
        data["ldap_username_attribute"] = ldap_username_attribute
    if ldap_additional_req is not None:
        data["ldap_additional_req"] = ldap_additional_req
    if ldap_use_ssl is not None:
        data["ldap_use_ssl"] = ldap_use_ssl
    if ldap_client_cert is not None:
        data["ldap_client_cert"] = ldap_client_cert
    if ldap_ca_cert is not None:
        data["ldap_ca_cert"] = ldap_ca_cert

    if save_template is not None:
        data["save_template"] = save_template


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



def delete_gateway_api(logger=None, url=None, CID=None, cloud_type=None, gateway_name=None, max_retry=10):
    ### Required parameters
    data = {
        "action": "delete_container",
        "CID": CID,
        "cloud_type": cloud_type,
        "gw_name": gateway_name
    }

    ### Optional parameters
    pass


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


