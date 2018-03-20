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

from lib.aws.account import get_aws_account_id

from lib.aviatrix.aviatrix_util import get_aviatrix_aws_iam_policy
from lib.aviatrix.aviatrix_util import read_aws_iam_role_document_to_string
from lib.aviatrix.aviatrix_util import download_aviatrix_aws_iam_policy


#######################################################################################################################
##########################################    IAM Policy     ##########################################################
#######################################################################################################################


def create_iam_policy(logger=None,
                      policy_name="",
                      policy_body_content="",
                      policy_description="",
                      aws_access_key_id="",
                      aws_secret_access_key="",
                      log_indentation=""
                      ):
    logger.info(log_indentation + "START: Create IAM Policy")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )
    
    try:
        ##### Step 01: Create IAM Policy
        response = iam_client.create_policy(
            PolicyName=policy_name,
            # Path='string',
            PolicyDocument=policy_body_content,  # Policy only accepts double quote instead of single quote
            Description=policy_description)

        ##### Step 02: Get Policy ID and ARN
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        policy_id = response["Policy"]["PolicyId"]
        policy_arn = response["Policy"]["Arn"]

        logger.info(log_indentation + "    Policy ID: " + policy_id)
        logger.info(log_indentation + "    Policy ARN: " + policy_arn)

        return policy_id, policy_arn

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create IAM Policy\n")



def delete_iam_policy(logger=None,
                      policy_arn="",
                      aws_access_key_id="",
                      aws_secret_access_key="",
                      log_indentation=""
                      ):
    logger.info(log_indentation + "START: Delete IAM Policy")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete IAM Policy
        response = iam_client.delete_policy(PolicyArn=policy_arn)
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete IAM Policy\n")




def attach_role_policy(logger=None,
                       role_name="",
                       policy_arn="",
                       aws_access_key_id="",
                       aws_secret_access_key="",
                       log_indentation=""
                       ):
    logger.info(log_indentation + "START: Attach IAM Role: " + role_name + " with IAM Policy: " + policy_arn)

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Attach
        response = iam_client.attach_role_policy(
            RoleName=role_name,
            PolicyArn=policy_arn
        )
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "END: Attach IAM Role: " + role_name + " with IAM Policy: " + policy_arn)




def detach_role_policy(logger=None,
                       role_name="",
                       policy_arn="",
                       aws_access_key_id="",
                       aws_secret_access_key="",
                       log_indentation=""
                       ):
    logger.info(log_indentation + "START: Detach IAM Role: " + role_name + " from IAM Policy: " + policy_arn)

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Detach
        response = iam_client.detach_role_policy(
            RoleName=role_name,
            PolicyArn=policy_arn
        )
        
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "END: Detach IAM Role: " + role_name + " from IAM Policy: " + policy_arn)



#######################################################################################################################
############################################    IAM Role     ##########################################################
#######################################################################################################################

def find_role(logger=None, target_role_name="", aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: Checking if the role: \"" + target_role_name + "\" already in AWS")

    try:
        role_exists = False
        role_names = list_roles_names(logger=logger,
                                      aws_access_key_id=aws_access_key_id,
                                      aws_secret_access_key=aws_secret_access_key,
                                      log_indentation=log_indentation+"    "
                                      )
        for name in role_names:
            if name == target_role_name:
                role_exists = True
    
        return role_exists
    
    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Checking if the role: \"" + target_role_name + "\" already in AWS\n")



def is_role_attached_with_policy(logger=None,
                                 role_name="",
                                 aws_access_key_id="",
                                 aws_secret_access_key="",
                                 log_indentation=""
                                 ):
    logger.info(log_indentation + "START: Check if the IAM Role: " + role_name + 
                " if already attached with at least one IAM policy.")

    iam_resource = boto3.resource(
        'iam',
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    # Step 01: Get the Role
    role = iam_resource.Role(role_name)

    # Step 02: Get the list of all policies attached to the role
    my_list = role.attached_policies.all()  # http://boto3.readthedocs.io/en/latest/reference/services/iam.html#IAM.Role.attached_policies

    # Step 03: Iterate the list, and if the name of the last policy is an empty string "" that means the role is not attached to any policy
    last_attached_policy_name = ""
    for policy in my_list:
        last_attached_policy_name = policy.policy_name
    # END for

    # Step 04: Return False if contains empty string, otherwise return True
    if last_attached_policy_name == "":
        return False
    # END IF

    logger.info(log_indentation + "ENDED: Check if the IAM Role: " + role_name +
                " if already attached with at least one IAM policy.\n")
    return True



def list_roles_names(logger=None, aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: List IAM Roles Names")

    try:
        ##### Step 01: List IAM Roles
        roles = list_roles(logger=logger,
                           aws_access_key_id=aws_access_key_id,
                           aws_secret_access_key=aws_secret_access_key,
                           log_indentation=log_indentation+"    "
                           )

        role_name_list = list()
        for role in roles:
            role_name_list.append(role["RoleName"])

        ##### Step 02: Get Roles into a py list
        logger.info(log_indentation + "    Succeed")
        return role_name_list

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: List IAM Roles Names\n")



def list_roles(logger=None, aws_access_key_id="", aws_secret_access_key="", log_indentation=""):
    logger.info(log_indentation + "START: List IAM Roles")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: List IAM Roles  # print(response)  -->>  {'Roles':[{'Path':'/','RoleName':'aviatrix-role-app','RoleId':'AROAJ3WT67WYU6EAHWPWQ','Arn':'arn:aws:iam::971302066566:role/aviatrix-role-app','CreateDate':datetime.datetime(2017,12,27,21,26,46,tzinfo=tzutc()),'AssumeRolePolicyDocument':{'Version':'2012-10-17','Statement':[{'Effect':'Allow','Principal':{'AWS':'arn:aws:iam::971302066566:root'},'Action':'sts:AssumeRole','Condition':{}}]}},{'Path':'/','RoleName':'aviatrix-role-ec2','RoleId':'AROAJFPP3NVRPSHWSKXEI','Arn':'arn:aws:iam::971302066566:role/aviatrix-role-ec2','CreateDate':datetime.datetime(2018,2,27,18,45,9,tzinfo=tzutc()),'AssumeRolePolicyDocument':{'Version':'2012-10-17','Statement':[{'Effect':'Allow','Principal':{'Service':'ec2.amazonaws.com'},'Action':'sts:AssumeRole'}]},'Description':'AllowsEC2instancestocallAWSservicesonyourbehalf.'}],'IsTruncated':False,'ResponseMetadata':{'RequestId':'5e1cfc03-2527-11e8-b787-51e450f7afe0','HTTPStatusCode':200,'HTTPHeaders':{'x-amzn-requestid':'5e1cfc03-2527-11e8-b787-51e450f7afe0','content-type':'text/xml','content-length':'1618','date':'Sun,11Mar201812:26:04GMT'},'RetryAttempts':0}}
        response = iam_client.list_roles(
            # PathPrefix='string',
            # Marker='string',
            # MaxItems=123
        )

        ##### Step 02: Get Roles into a py list
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        roles = response["Roles"]
        return roles

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: List IAM Roles\n")





def create_role(logger=None, 
                role_name="", 
                role_policy_document="", 
                role_description="",
                aws_access_key_id="",
                aws_secret_access_key="",
                log_indentation=""
                ):
    logger.info(log_indentation + "START: Create IAM Role: " + role_name)

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 04: Create Aviatrix Role
        response = iam_client.create_role(
            Path="/",
            RoleName=role_name,
            AssumeRolePolicyDocument=role_policy_document,  # EC2 role and APP role takes different RolePolicyDocuments
            Description=role_description
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Role Attributes
        role_id  = response["Role"]["RoleId"]
        role_arn = response["Role"]["Arn"]

        return role_id, role_arn

    except iam_client.exceptions.EntityAlreadyExistsException as e:
        logger.info(log_indentation + "WARNING: The role: " + role_name + 
                    " that you're trying to create already exists.")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create IAM Role\n")




def get_iam_role_arn(logger=None,
                     iam_role_name=None,
                     aws_access_key_id="",
                     aws_secret_access_key="",
                     log_indentation=""
                     ):
    logger.info(log_indentation + "START: Get IAM Role ARN")
    try:
        iam_resource = boto3.resource(
            "iam",
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key
        )
        role = iam_resource.Role(iam_role_name)
        return role.arn

    except Exception as e:
        logger.error("error: Opps! Exception/Error has occurred!")
        traceback_msg = traceback.format_exc()
        logger.info(traceback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Get IAM Role ARN\n")




def delete_aviatrix_role(logger=None,
                         role_name="",
                         aws_access_key_id="",
                         aws_secret_access_key="",
                         log_indentation=""
                         ):
    logger.info(log_indentation + "START: Delete Aviatrix Role: " + role_name)

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 04: Delete Aviatrix Role
        response = iam_client.delete_role(RoleName=role_name)
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except iam_client.exceptions.NoSuchEntityException as e:
        logger.error(log_indentation + "ERROR: The IAM role you're trying to delete doesn't exist.")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Delete Aviatrix Role\n")



"""
Description:
    * Create EC2 Role if not existed
    * Create Instance-Profile and associate it with Role
    * Create IAM-Policy and attach to Role
    * return True if successfully created by the function, and return Instance-ProfileARN
"""
def create_aviatrix_role_ec2(
        logger=None,
        role_name="aviatrix-role-ec2",
        path_to_role_document="./config/assume_role_policy_document_for_ec2_role.txt",
        policy_name="aviatrix-ec2-policy",
        url_to_assume_role_policy="https://s3-us-west-2.amazonaws.com/aviatrix-download/iam_assume_role_policy.txt",
        path_to_policy_file="./result/aviatrix-ec2-policy.txt",
        aws_access_key_id="",
        aws_secret_access_key="",
        log_indentation=""
        ):
    logger.info(log_indentation + "START: Create Aviatrix EC2 Role")

    role_created_by_this_function = False
    role_already_exists = False
    instance_profile_arn = "arn:aws:iam::AWS_ACCOUNT_ID:instance-profile/aviatrix-role-ec2"

    try:
        ##### IAM Role Creation Step 01: Find out if "aviatrix-role-ec2" exists
        logger.info(log_indentation + "    IAM Role Creation Step 01: Find out if " + role_name + " exists")
        role_already_exists = find_role(logger=logger,
                                        target_role_name=role_name,
                                        aws_access_key_id=aws_access_key_id,
                                        aws_secret_access_key=aws_secret_access_key,
                                        log_indentation=log_indentation+"    "
                                        )
        logger.info(log_indentation + "        " + role_name + " already exists? " + str(role_already_exists) + "\n")

        ### IF role already exists, then return False, and Default Instance-Profile ARN
        if role_already_exists and is_role_attached_with_policy(logger=logger,
                                                                role_name=role_name,
                                                                aws_access_key_id=aws_access_key_id,
                                                                aws_secret_access_key=aws_secret_access_key,
                                                                log_indentation=log_indentation+"    "):
            aws_account_id = get_aws_account_id(logger=logger,
                                                aws_access_key_id=aws_access_key_id,
                                                aws_secret_access_key=aws_secret_access_key,
                                                log_indentation=log_indentation
                                                )
            instance_profile_arn = instance_profile_arn.replace("AWS_ACCOUNT_ID", aws_account_id)
            return role_created_by_this_function, instance_profile_arn
        # END checking if aviatrix-role-ec2 already exists AND already has at least one or more policy attached


        ##### IAM Role Creation Step 02: Read Role-Policy-Document from local
        logger.info(log_indentation + "    IAM Role Creation Step 02: Read Role-Policy-Document from local")
        role_policy_document = read_aws_iam_role_document_to_string(
            logger=logger,
            path_to_role_document=path_to_role_document,
            is_app_role=False,
            log_indentation=log_indentation+"    "
        )

        ##### IAM Role Creation Step 03: Create IAM Role with Role-Policy-Document
        logger.info(log_indentation + "    IAM Role Creation Step 03: Create IAM Role")
        role_id, role_arn = create_role(logger=logger,
                                        role_name=role_name,
                                        role_policy_document=role_policy_document,
                                        aws_access_key_id=aws_access_key_id,
                                        aws_secret_access_key=aws_secret_access_key,
                                        log_indentation=log_indentation+"    "
                                        )
        if role_id:
            role_created_by_this_function = True


        ##### Instance Profile Creation: Step 01: Create Instance Profile
        logger.info(log_indentation + "    Instance Profile Creation: Step 01: Create Instance Profile")
        instance_profile_name, instance_profile_id, instance_profile_arn = create_iam_instance_profile(
            logger=logger,
            instance_profile_name=role_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation=log_indentation+"    "
        )


        ##### Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile
        logger.info(log_indentation + "    Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile")
        add_role_to_instance_profile(logger=logger,
                                     role_name=role_name,
                                     instance_profile_name=instance_profile_name,
                                     aws_access_key_id=aws_access_key_id,
                                     aws_secret_access_key=aws_secret_access_key,
                                     log_indentation=log_indentation+"    "
                                     )
        # time.sleep(10)  # Might be needed


        ##### IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local
        logger.info(log_indentation + 
                    "    IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local")
        download_aviatrix_aws_iam_policy(logger=logger, 
                                         url=url_to_assume_role_policy, 
                                         save_to=path_to_policy_file,
                                         log_indentation=log_indentation+"    ")


        ##### IAM Policy Creation Step 03: Read IAM Policy from local
        logger.info(log_indentation + "    IAM Policy Creation Step 03: Read IAM Policy from local")
        with open(path_to_policy_file, "r") as input_file_stream:
            policy_content = input_file_stream.read()


        # Give policy_arn a default value in case creation fails
        logger.info(log_indentation +
                    "    Give policy_arn a default value in case creation fails due to policy already exists")
        aws_account_id = get_aws_account_id(logger=logger,
                                            aws_access_key_id=aws_access_key_id,
                                            aws_secret_access_key=aws_secret_access_key,
                                            log_indentation=log_indentation+"    "
                                            )
        policy_arn = "arn:aws:iam::AWS_ACCOUNT_ID:policy/aviatrix-ec2-policy"
        policy_arn = policy_arn.replace("AWS_ACCOUNT_ID", aws_account_id)
        try: # The reason why "try-except" the code here is because we can continue to attach Role & Policy if Policy creation fails due to already exists
            ##### IAM Policy Creation Step 03: Create IAM Policy
            logger.info(log_indentation + "    IAM Policy Creation Step 03: Create IAM Policy")
            policy_id, policy_arn = create_iam_policy(logger=logger,
                                                      policy_name=policy_name,
                                                      policy_body_content=policy_content,
                                                      aws_access_key_id=aws_access_key_id,
                                                      aws_secret_access_key=aws_secret_access_key,
                                                      log_indentation=log_indentation+"    "
                                                      )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.info(tracekback_msg)


        ##### Attach IAM Role & IAM Policy
        logger.info(log_indentation + "    Attach IAM Role & IAM Policy")
        attach_role_policy(logger=logger,
                           role_name=role_name,
                           policy_arn=policy_arn,
                           aws_access_key_id=aws_access_key_id,
                           aws_secret_access_key=aws_secret_access_key,
                           log_indentation=log_indentation+"    "
        )

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Aviatrix EC2 Role\n")
        return role_created_by_this_function, instance_profile_arn



"""
Description:
    * Create APP Role if not existed
    * Create IAM-Policy and attach to Role
    * return True if successfully created by the function
"""
def create_aviatrix_role_app(logger=None, 
        aws_account_id="",
        role_name="aviatrix-role-app",
        path_to_role_document="./config/assume_role_policy_document_for_app_role.txt",
        policy_name="aviatrix-app-policy",
        url_to_app_policy="https://s3-us-west-2.amazonaws.com/aviatrix-download/IAM_access_policy_for_CloudN.txt",
        path_to_policy_file="./result/aviatrix-app-policy.txt",
        aws_access_key_id="",
        aws_secret_access_key="",
        log_indentation=""
        ):
    logger.info(log_indentation + "START: Create Aviatrix APP Role")

    role_created_by_this_function = False
    role_already_exists = False

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )
    
    iam_resource = boto3.resource(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### IAM Role Creation Step 01: Find out if "aviatrix-role-app" exists
        logger.info(log_indentation + "    IAM Role Creation Step 01: Find out if " + role_name + " exists")
        role_already_exists = find_role(logger=logger,
                                        target_role_name=role_name,
                                        aws_access_key_id=aws_access_key_id,
                                        aws_secret_access_key=aws_secret_access_key,
                                        log_indentation=log_indentation+"    "
                                        )
        logger.info(log_indentation + "        " + role_name + " already exists? " + str(role_already_exists) + "\n")
        if role_already_exists:
            return role_created_by_this_function


        ##### IAM Role Creation Step 02: Get Role-Policy-Document from local
        logger.info(log_indentation + "    IAM Role Creation Step 02: Get Role-Policy-Document from local")
        role_policy_document = read_aws_iam_role_document_to_string(
            logger=logger,
            path_to_role_document=path_to_role_document,
            is_app_role=False,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation=log_indentation+"    "
            )
        role_policy_document = role_policy_document.replace("MY_ACCOUNT_ID", aws_account_id)

        logger.info(log_indentation + "    Path to role doc: " + path_to_role_document)
        logger.info(log_indentation + "    APP Role Policy Document :")
        logger.info("\n" + str(role_policy_document))


        ##### IAM Role Creation Step 03: Create IAM Role with Role-Policy-Document
        logger.info(log_indentation + "    IAM Role Creation Step 03: Create IAM Role")
        response = create_role(
            logger=logger,
            role_name=role_name,
            role_policy_document=role_policy_document,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            log_indentation=log_indentation+"    "
        )
        if response:
            role_created_by_this_function = True

        ##### Instance Profile Creation: Step 01: Create Instance Profile
        # logger.info("    Instance Profile Creation: Step 01: Create Instance Profile")
        # instance_profile_name, instance_profile_id, instance_profile_arn = create_iam_instance_profile(role_name)


        ##### Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile
        # logger.info("Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile")
        # add_role_to_instance_profile(role_name=role_name, instance_profile_name=instance_profile_name)
        # # time.sleep(10)  # Might be needed


        ##### IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local
        logger.info(log_indentation + 
                    "    IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local")
        download_aviatrix_aws_iam_policy(logger=logger, 
                                         url=url_to_app_policy, 
                                         save_to=path_to_policy_file,
                                         log_indentation=log_indentation+"    ")


        ##### IAM Policy Creation Step 03: Read IAM Policy from local
        logger.info(log_indentation + "    IAM Policy Creation Step 03: Read IAM Policy from local")
        with open(path_to_policy_file, "r") as input_file_stream:
            policy_content = input_file_stream.read()


        # Give policy_arn a default value in case creation fails
        policy_arn = "arn:aws:iam::AWS_ACCOUNT_ID:policy/aviatrix-app-policy"
        policy_arn = policy_arn.replace("AWS_ACCOUNT_ID", aws_account_id)
        try:  # The reason why "try-except" the code here is because we can continue to attach Role & Policy if Policy creation fails due to already exists
            ##### IAM Policy Creation Step 03: Create IAM Policy
            logger.info("    IAM Policy Creation Step 03: Create IAM Policy")
            policy_id, policy_arn = create_iam_policy(logger=logger,
                                                      policy_name=policy_name,
                                                      policy_body_content=policy_content,
                                                      aws_access_key_id=aws_access_key_id,
                                                      aws_secret_access_key=aws_secret_access_key,
                                                      log_indentation=log_indentation+"    "
                                                      )
        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.info(tracekback_msg)


        ##### Attach IAM Role & IAM Policy
        logger.info(log_indentation + "    Attach IAM Role & IAM Policy")
        attach_role_policy(logger=logger,
                           role_name=role_name,
                           policy_arn=policy_arn,
                           aws_access_key_id=aws_access_key_id,
                           aws_secret_access_key=aws_secret_access_key,
                           log_indentation=log_indentation+"    "
                           )

        return role_created_by_this_function

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create Aviatrix APP Role\n")




#######################################################################################################################
####################################    IAM Instance Profile     ######################################################
#######################################################################################################################

def create_iam_instance_profile(logger=None,
                                instance_profile_name="",
                                aws_access_key_id="",
                                aws_secret_access_key="",
                                log_indentation=""
                                ):
    logger.info(log_indentation + "START: Create IAM Instance Profile")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Create IAM Instance Profile
        response = iam_client.create_instance_profile(
            InstanceProfileName=instance_profile_name
            # Path='string'
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))

        ##### Step 02: Get Profile Attributes
        instance_profile_name = response["InstanceProfile"]["InstanceProfileName"]
        instance_profile_id   = response["InstanceProfile"]["InstanceProfileId"]
        instance_profile_arn  = response["InstanceProfile"]["Arn"]
        logger.info(log_indentation + "    IAM Instance Profile Name: " + instance_profile_name)
        logger.info(log_indentation + "    IAM Instance Profile ID  : " + instance_profile_id)
        logger.info(log_indentation + "    IAM Instance Profile ARN : " + instance_profile_arn)

        return instance_profile_name, instance_profile_id, instance_profile_arn

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Create IAM Instance Profile\n")



def delete_iam_instance_profile(logger=None,
                                instance_profile_name="",
                                aws_access_key_id="",
                                aws_secret_access_key="",
                                log_indentation=""
                                ):
    logger.info(log_indentation + "START: Delete IAM Instance Profile")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Delete IAM Instance Profile
        response = iam_client.delete_instance_profile(
            InstanceProfileName=instance_profile_name
        )
        
        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "END:: Delete IAM Instance Profile")




def add_role_to_instance_profile(logger=None,
                                 role_name="",
                                 instance_profile_name="",
                                 aws_access_key_id="",
                                 aws_secret_access_key="",
                                 log_indentation=""
                                 ):
    logger.info(log_indentation + "START: Add IAM Role to IAM Instance Profile")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Add IAM Role to IAM Instance Profile
        response = iam_client.add_role_to_instance_profile(
            InstanceProfileName=instance_profile_name,
            RoleName=role_name
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Add IAM Role to IAM Instance Profile\n")




def remove_role_from_instance_profile(logger=None,
                                      role_name="",
                                      instance_profile_name="",
                                      aws_access_key_id="",
                                      aws_secret_access_key="",
                                      log_indentation=""
                                      ):
    logger.info(log_indentation + "START: Remove IAM-Role from the Instance-Profie")

    iam_client = boto3.client(
        service_name='iam', 
        aws_access_key_id=aws_access_key_id, 
        aws_secret_access_key=aws_secret_access_key
    )

    try:
        ##### Step 01: Remove IAM-Role from the Instance-Profie
        response = iam_client.remove_role_from_instance_profile(
            InstanceProfileName=instance_profile_name,
            RoleName=role_name
        )

        logger.info(log_indentation + "    Succeed")
        logger.info(log_indentation + "    " + str(response))
        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        logger.info(tracekback_msg)

    finally:
        logger.info(log_indentation + "ENDED: Remove IAM-Role from the Instance-Profie\n")


