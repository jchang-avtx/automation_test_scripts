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


def create_iam_policy(policy_name="", policy_body_content="", policy_description=""):
    print("\nSTART: Create IAM Policy")

    iam_client   = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Create IAM Policy
        response = iam_client.create_policy(
            PolicyName=policy_name,
            # Path='string',
            PolicyDocument=policy_body_content,  # Policy only accepts double quote instead of single quote
            Description=policy_description)

        ##### Step 02: Get Policy ID and ARN
        print("    Succeed")

        policy_id = response["Policy"]["PolicyId"]
        policy_arn = response["Policy"]["Arn"]

        print("    Policy ID: " + policy_id)
        print("    Policy ARN: " + policy_arn)

        print("ENDED: Create IAM Policy\n")

        return policy_id, policy_arn


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



def delete_iam_policy(policy_arn=""):
    print("\nSTART: Delete IAM Policy")

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Delete IAM Policy
        response = iam_client.delete_policy(PolicyArn=policy_arn)
        print("    Succeed")
        print("ENDED: Delete IAM Policy\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



def attach_role_policy(role_name="", policy_arn=""):
    print("\nSTART: Attach IAM Role: " + role_name + " with IAM Policy: " + policy_arn)

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Attach
        response = iam_client.attach_role_policy(
            RoleName=role_name,
            PolicyArn=policy_arn
        )
        print("    Succeed")
        print("\nEND: Attach IAM Role: " + role_name + " with IAM Policy: " + policy_arn)

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



def detach_role_policy(role_name="", policy_arn=""):
    print("\nSTART: Detach IAM Role: " + role_name + " from IAM Policy: " + policy_arn)

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Detach
        response = iam_client.detach_role_policy(
            RoleName=role_name,
            PolicyArn=policy_arn
        )
        print("    Succeed")
        print("\nEND: Detach IAM Role: " + role_name + " from IAM Policy: " + policy_arn)

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass


#######################################################################################################################
############################################    IAM Role     ##########################################################
#######################################################################################################################

def find_role(target_role_name=""):
    print("\nSTART: Checking if the role: \"" + target_role_name + "\" already in AWS")

    role_exists = False
    roles_names = list_roles_names()

    for name in roles_names:
        if name == target_role_name:
            role_exists = True

    print("\nEND: Checking if the role: \"" + target_role_name + "\" already in AWS")
    return role_exists



def list_roles_names():
    print("\nSTART: List IAM Roles Names")

    try:
        ##### Step 01: List IAM Roles
        roles = list_roles()
        role_name_list = list()

        for role in roles:
            role_name_list.append(role["RoleName"])

        ##### Step 02: Get Roles into a py list
        print("    Succeed")
        print("ENDED: List IAM Roles Names\n")
        return role_name_list

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



""" response looks like

{
  'Roles': [
    {
      'Path': '/',
      'RoleName': 'aviatrix-role-app',
      'RoleId': 'AROAJ3WT67WYU6EAHWPWQ',
      'Arn': 'arn:aws:iam::971302066566:role/aviatrix-role-app',
      'CreateDate': datetime.datetime(2017,
      12,
      27,
      21,
      26,
      46,
      tzinfo=tzutc()),
      'AssumeRolePolicyDocument': {
        'Version': '2012-10-17',
        'Statement': [
          {
            'Effect': 'Allow',
            'Principal': {
              'AWS': 'arn:aws:iam::971302066566:root'
            },
            'Action': 'sts:AssumeRole',
            'Condition': {}
          }
        ]
      }
    },
    {
      'Path': '/',
      'RoleName': 'aviatrix-role-ec2',
      'RoleId': 'AROAJFPP3NVRPSHWSKXEI',
      'Arn': 'arn:aws:iam::971302066566:role/aviatrix-role-ec2',
      'CreateDate': datetime.datetime(2018,
      2,
      27,
      18,
      45,
      9,
      tzinfo=tzutc()),
      'AssumeRolePolicyDocument': {
        'Version': '2012-10-17',
        'Statement': [
          {
            'Effect': 'Allow',
            'Principal': {
              'Service': 'ec2.amazonaws.com'
            },
            'Action': 'sts:AssumeRole'
          }
        ]
      },
      'Description': 'Allows EC2 instances to call AWS services on your behalf.'
    }
  ],
  'IsTruncated': False,
  'ResponseMetadata': {
    'RequestId': '5e1cfc03-2527-11e8-b787-51e450f7afe0',
    'HTTPStatusCode': 200,
    'HTTPHeaders': {
      'x-amzn-requestid': '5e1cfc03-2527-11e8-b787-51e450f7afe0',
      'content-type': 'text/xml',
      'content-length': '1618',
      'date': 'Sun, 11 Mar 2018 12:26:04 GMT'
    },
    'RetryAttempts': 0
  }
}

"""
def list_roles():
    print("\nSTART: List IAM Roles")

    iam_client   = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: List IAM Roles
        response = iam_client.list_roles(
            # PathPrefix='string',
            # Marker='string',
            # MaxItems=123
        )

        ##### Step 02: Get Roles into a py list
        print("    Succeed")
        roles = response["Roles"]
        print("ENDED: List IAM Roles\n")
        return roles

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass




def create_role(role_name="", role_policy_document="", role_description=""):
    print("\nSTART: Create IAM Role: " + role_name)

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 04: Create Aviatrix Role
        response = iam_client.create_role(
            Path="/",
            RoleName=role_name,
            AssumeRolePolicyDocument=role_policy_document,  # EC2 role and APP role takes different RolePolicyDocuments
            Description=role_description
        )

        ##### Step 02: Get Role Attributes
        print("    Succeed")
        role_id  = response["Role"]["RoleId"]
        role_arn = response["Role"]["Arn"]
        print("ENDED: Create IAM Role\n")

        return role_id, role_arn

    except iam_client.exceptions.EntityAlreadyExistsException as e:
        print("WARNING: The role: " + role_name + " that you're trying to create already exists.")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



def get_iam_role_arn(iam_role_name=None):
    try:
        iam_client = boto3.resource("iam")
        role = iam_client.Role(iam_role_name)

        return role.arn

    except Exception as e:
        print("error: Opps! Exception/Error has occurred!")
        traceback_msg = traceback.format_exc()
        print(traceback_msg)

    finally:
        pass



def delete_aviatrix_role(role_name=""):
    print("\nSTART: Delete Aviatrix Role: " + role_name)

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 04: Delete Aviatrix Role
        response = iam_client.delete_role(RoleName=role_name)
        print("    Succeed")
        print("ENDED: Delete Aviatrix Role\n")

        return True

    except iam_client.exceptions.NoSuchEntityException as e:
        print("info: The IAM role you're trying to delete doesn't exist.")

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass


"""
Description:
    * Create EC2 Role if not existed
    * Create Instance-Profile and associate it with Role
    * Create IAM-Policy and attach to Role
    * return True if successfully created by the function, and return Instance-ProfileARN
"""
def create_aviatrix_role_ec2(
        role_name="aviatrix-role-ec2",
        path_to_role_document="./config/assume_role_policy_document_for_ec2_role.txt",
        policy_name="aviatrix-ec2-policy",
        url_to_assume_role_policy="https://s3-us-west-2.amazonaws.com/aviatrix-download/iam_assume_role_policy.txt",
        path_to_policy_file="./result/aviatrix-ec2-policy.txt"
):
    print("\nSTART: Create Aviatrix EC2 Role")

    role_created_by_this_function = False
    role_already_exists = False
    instance_profile_arn = "arn:aws:iam::AWS_ACCOUNT_ID:instance-profile/aviatrix-role-ec2"


    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### IAM Role Creation Step 01: Find out if "aviatrix-role-ec2" exists
        print("    IAM Role Creation Step 01: Find out if " + role_name + " exists")
        role_already_exists = find_role(target_role_name=role_name)
        print("        " + role_name + " already exists? " + str(role_already_exists))

        ### IF role already exists, then return False, and Default Instance-Profile ARN
        if role_already_exists:
            aws_account_id = get_aws_account_id()
            instance_profile_arn = instance_profile_arn.replace("AWS_ACCOUNT_ID", aws_account_id)
            return role_created_by_this_function, instance_profile_arn


        ##### IAM Role Creation Step 02: Get Role-Policy-Document from local
        print("    IAM Role Creation Step 02: Get Role-Policy-Document from local")
        role_policy_document = read_aws_iam_role_document_to_string(
            path_to_role_document=path_to_role_document,
            is_app_role=False
        )

        ##### IAM Role Creation Step 03: Create IAM Role with Role-Policy-Document
        print("    IAM Role Creation Step 03: Create IAM Role")
        role_id, role_arn = create_role(role_name=role_name, role_policy_document=role_policy_document)
        if role_id:
            role_created_by_this_function = True


        ##### Instance Profile Creation: Step 01: Create Instance Profile
        print("    Instance Profile Creation: Step 01: Create Instance Profile")
        instance_profile_name, instance_profile_id, instance_profile_arn = create_iam_instance_profile(role_name)


        ##### Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile
        print("Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile")
        add_role_to_instance_profile(role_name=role_name, instance_profile_name=instance_profile_name)
        # time.sleep(10)  # Might be needed


        ##### IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local
        print("    IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local")
        download_aviatrix_aws_iam_policy(url=url_to_assume_role_policy, save_to=path_to_policy_file)


        ##### IAM Policy Creation Step 03: Read IAM Policy from local
        print("    IAM Policy Creation Step 03: Read IAM Policy from local")
        with open(path_to_policy_file, "r") as input_file_stream:
            policy_content = input_file_stream.read()


        ##### IAM Policy Creation Step 03: Create IAM Policy
        print("    IAM Policy Creation Step 03: Create IAM Policy")
        policy_id, policy_arn = create_iam_policy(policy_name=policy_name, policy_body_content=policy_content)


        ##### Attach IAM Role & IAM Policy
        print("    Attach IAM Role & IAM Policy")
        attach_role_policy(role_name=role_name, policy_arn=policy_arn)


        print("ENDED: Create Aviatrix EC2 Role\n")
        return role_created_by_this_function, instance_profile_arn

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        return False



"""
Description:
    * Create APP Role if not existed
    * Create IAM-Policy and attach to Role
    * return True if successfully created by the function
"""
def create_aviatrix_role_app(
        aws_account_id="",
        role_name="aviatrix-role-app",
        path_to_role_document="./config/assume_role_policy_document_for_app_role.txt",
        policy_name="aviatrix-app-policy",
        url_to_app_policy="https://s3-us-west-2.amazonaws.com/aviatrix-download/IAM_access_policy_for_CloudN.txt",
        path_to_policy_file="./result/aviatrix-app-policy.txt",
        aws_access_key_id="",
        aws_secret_access_key=""):
    print("\nSTART: Create Aviatrix APP Role")

    role_created_by_this_function = False
    role_already_exists = False

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### IAM Role Creation Step 01: Find out if "aviatrix-role-app" exists
        print("    IAM Role Creation Step 01: Find out if " + role_name + " exists")
        role_already_exists = find_role(target_role_name=role_name)
        print("        " + role_name + " already exists? " + str(role_already_exists))
        if role_already_exists:
            return role_created_by_this_function


        ##### IAM Role Creation Step 02: Get Role-Policy-Document from local
        print("    IAM Role Creation Step 02: Get Role-Policy-Document from local")
        role_policy_document = read_aws_iam_role_document_to_string(
            path_to_role_document=path_to_role_document,
            is_app_role=False
        )
        role_policy_document = role_policy_document.replace("MY_ACCOUNT_ID", aws_account_id)

        print("Path to role doc: " + path_to_role_document)
        print("type(role_policy_document) == " + str(type(role_policy_document)))
        print("Role Policy Document ...")
        print(role_policy_document)


        ##### IAM Role Creation Step 03: Create IAM Role with Role-Policy-Document
        print("    IAM Role Creation Step 03: Create IAM Role")
        create_role(role_name=role_name, role_policy_document=role_policy_document)


        ##### Instance Profile Creation: Step 01: Create Instance Profile
        # print("    Instance Profile Creation: Step 01: Create Instance Profile")
        # instance_profile_name, instance_profile_id, instance_profile_arn = create_iam_instance_profile(role_name)


        ##### Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile
        # print("Instance Profile Creation: Step 02:  Add EC2 Role to Instance-Profile")
        # add_role_to_instance_profile(role_name=role_name, instance_profile_name=instance_profile_name)
        # # time.sleep(10)  # Might be needed


        ##### IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local
        print("    IAM Policy Creation Step 01: Download the AWS Policy from Aviatrix Website to local")
        download_aviatrix_aws_iam_policy(url=url_to_app_policy, save_to=path_to_policy_file)


        ##### IAM Policy Creation Step 03: Read IAM Policy from local
        print("    IAM Policy Creation Step 03: Read IAM Policy from local")
        with open(path_to_policy_file, "r") as input_file_stream:
            policy_content = input_file_stream.read()


        ##### IAM Policy Creation Step 03: Create IAM Policy
        print("    IAM Policy Creation Step 03: Create IAM Policy")
        policy_id, policy_arn = create_iam_policy(policy_name=policy_name, policy_body_content=policy_content)


        ##### Attach IAM Role & IAM Policy
        print("    Attach IAM Role & IAM Policy")
        attach_role_policy(role_name=role_name, policy_arn=policy_arn)


        print("ENDED: Create Aviatrix APP Role\n")
        return role_created_by_this_function

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



#######################################################################################################################
####################################    IAM Instance Profile     ######################################################
#######################################################################################################################

def create_iam_instance_profile(instance_profile_name=""):
    print("\nSTART: Create IAM Instance Profile")

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Create IAM Instance Profile
        response = iam_client.create_instance_profile(
            InstanceProfileName=instance_profile_name
            # Path='string'
        )

        print("    Succeed")

        ##### Step 02: Get Profile Attributes
        instance_profile_name = response["InstanceProfile"]["InstanceProfileName"]
        instance_profile_id   = response["InstanceProfile"]["InstanceProfileId"]
        instance_profile_arn  = response["InstanceProfile"]["Arn"]
        print("    IAM Instance Profile Name: " + instance_profile_name)
        print("    IAM Instance Profile ID  : " + instance_profile_id)
        print("    IAM Instance Profile ARN : " + instance_profile_arn)

        print("ENDED: Create IAM Instance Profile\n")

        return instance_profile_name, instance_profile_id, instance_profile_arn

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass


def delete_iam_instance_profile(instance_profile_name=""):
    print("\nSTART: Delete IAM Instance Profile")

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Delete IAM Instance Profile
        response = iam_client.delete_instance_profile(
            InstanceProfileName=instance_profile_name
        )
        print("    Succeed")
        print("\nENDED: Delete IAM Instance Profile")

        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



def add_role_to_instance_profile(role_name="", instance_profile_name=""):
    print("\nSTART: Add IAM Role to IAM Instance Profile")

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Add IAM Role to IAM Instance Profile
        response = iam_client.add_role_to_instance_profile(
            InstanceProfileName=instance_profile_name,
            RoleName=role_name
        )

        ##### Step 02: Get XXXXX_somthing_XXXXX
        print("    Succeed")
        print("ENDED: Add IAM Role to IAM Instance Profile\n")

        return True


    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass




def remove_role_from_instance_profile(role_name="", instance_profile_name=""):
    print("\nSTART: Remove IAM-Role from the Instance-Profie")

    iam_client = boto3.client(service_name='iam')
    iam_resource = boto3.resource(service_name='iam')

    try:
        ##### Step 01: Remove IAM-Role from the Instance-Profie
        response = iam_client.remove_role_from_instance_profile(
            InstanceProfileName=instance_profile_name,
            RoleName=role_name
        )
        print("    Succeed")
        print("ENDED: Remove IAM-Role from the Instance-Profie\n")

        return True

    except Exception as e:
        tracekback_msg = traceback.format_exc()
        print(tracekback_msg)

    finally:
        pass



