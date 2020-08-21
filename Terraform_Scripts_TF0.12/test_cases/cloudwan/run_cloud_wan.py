"""
run_cloud_wan.py

Test case for CloudWAN Terraform use-case

- note various placeholders that must be updated:
    - filepath for terraform_fx.py
    - create/ import/ update/ destroy test functions and respective arguments
    - update "#" in "avx_ip_#", "avx_user_#", "avx_pass_#" accordingly
- place xxx.py in respective test_cases/xxx/ directory
"""

import os

import sys
sys.path.insert(1, '/var/lib/jenkins/workspace/Terraform-Regression/py_libs')
import terraform_fx as tf

import logging
import logging.handlers
import time

TIMESTR = time.strftime("%Y-%m-%d")
LOGLEVEL = logging.DEBUG
FORMAT = "%(asctime)s - %(levelname)s - %(message)s"
DATEFORMAT = "%d-%b-%y %H:%M:%S"
logging.basicConfig(level=LOGLEVEL,
                    format=FORMAT,
                    datefmt=DATEFORMAT,
                    handlers=[
                        logging.FileHandler(filename=os.getcwd() + "/logs/" + TIMESTR + "_regression_result.log"),
                        logging.StreamHandler()
                    ])
log = logging.getLogger()

secret_path = "/var/lib/jenkins/tf-secrets/cloudwan/"
cred_file = "cloudwan_cred"
cred_path = secret_path + cred_file

log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: " + str(os.path.split(os.getcwd())[1]).upper())
log.info("============================================================")
log.info("Steps to perform:")
log.info("      1. Set up environment variables/ credentials")
log.info("      2. Create AWS networking infrastructure (CSR device etc)")
log.info("      3. Create CloudWAN branch router, tags, interface configs")
log.info("      4. Set up transit attachment, TGW attachment and Virtual WAN attachments")
log.info("      5. Perform import tests and note any deltas")
log.info("      6. Tear down infrastructure\n")

try:
    log.info("Setting environment...")
    log.debug("     placeholder_ip: %s", str(os.environ["AVIATRIX_CONTROLLER_IP"]))
    log.debug("     placeholder_user: %s", str(os.environ["AVIATRIX_USERNAME"]))
    log.debug("     placeholder_pass: %s", str(os.environ["AVIATRIX_PASSWORD"]))
    avx_controller_ip = os.environ["avx_ip_1"]
    avx_controller_user = os.environ["avx_user_1"]
    avx_controller_pass = os.environ["avx_pass_1"]
    log.info("Setting new variable values as follows...")
    log.debug("     avx_controller_ip: %s", avx_controller_ip)
    log.debug("     avx_controller_user: %s", avx_controller_user)
    log.debug("     avx_controller_pass: %s", avx_controller_pass)
    os.environ["AVIATRIX_CONTROLLER_IP"] = avx_controller_ip
    os.environ["AVIATRIX_USERNAME"] = avx_controller_user
    os.environ["AVIATRIX_PASSWORD"] = avx_controller_pass
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     Failed to properly set environment credentials!")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      Set environment credentials: PASS\n")


for i in range(3):
    try:
        log.info("Creating infrastructure...")
        tf.create_verify(varfile=cred_path)
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*i)
        if i == 2:
            log.info("-------------------- RESULT --------------------")
            log.error("     CloudWAN infrastructure: FAIL\n")
            sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      CloudWAN infrastructure: PASS\n")
        break


for j in range(3):
    try:
        log.debug("     transit gateway attachment status : true...")
        tf.create_verify(varfile=cred_path, varval="avx_transit_att_status=true")
        log.debug("Verifying import funcionality...")
        tf.import_test("device_transit_gateway_attachment", "csr_transit_att", varfile=cred_path, varval="avx_transit_att_status=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*j)
        if j == 2:
            log.info("-------------------- RESULT --------------------")
            log.error("     transit gateway attachment: FAIL\n")
            sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      transit gateway attachment: PASS\n")
        break


for k in range(3):
    try:
        log.debug("     TGW attachment status : true...")
        tf.create_verify(varfile=cred_path, varval="aws_tgw_att_status=true")
        log.debug("Verifying import functionality...")
        tf.import_test("device_aws_tgw_attachment", "csr_tgw_att", varfile=cred_path, varval="aws_tgw_att_status=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*k)
        if k == 2:
            log.info("-------------------- RESULT --------------------")
            log.error("     TGW attachment: FAIL\n")
            sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      TGW attachment: PASS\n")
        break


for l in range(3):
    try:
        log.debug("     Virtual WAN attachment status : true...")
        tf.create_verify(varfile=cred_path, varval="azure_virtual_wan_att_status=true")
        log.debug("Verifying import functionality...")
        tf.import_test("device_virtual_wan_attachment", "csr_virtual_wan_att", varfile=cred_path, varval="azure_virtual_wan_att_status=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*l)
        if l == 2:
            log.info("-------------------- RESULT --------------------")
            log.error("     Virtual WAN attachment: FAIL\n")
            sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      Virtual WAN attachment: PASS\n")
        break


for m in range(3):
    try:
        log.info("Verifying destroy functionality...")
        tf.destroy_test(varfile=cred_path)
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*m)
        if m == 2:
            log.info("-------------------- RESULT --------------------")
            log.error("     destroy_test(): FAIL\n")
            sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      destroy_test(): PASS\n")
        sys.exit(0)
