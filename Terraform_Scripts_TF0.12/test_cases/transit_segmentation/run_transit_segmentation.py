"""
run_transit_segmentation.py

Test case for Aviatrix Multi-cloud Transit Segmentation Terraform use-case

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

def return_result(test, result):
    """
    test is string ; result is string
    if result == true is PASS
    if result == false is FALSE
    """
    log.info("-------------------- RESULT --------------------")
    if result:
        log.info("     " + test + "(): " + "PASS\n")
    else:
        log.error("     " + test + "(): " + "FAIL\n")

log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: " + str(os.path.split(os.getcwd())[1]).upper())
log.info("============================================================")
log.info("Steps to perform:")
log.info("      1. Set up environment variables/ credentials")
log.info("      2. Create underlying infrastructure (on-prem simulation)")
log.info("      3. Create transit networks of various cloud types")
log.info("      4. Create segmentation within the various clouds")
log.info("      5. Perform import tests and note any deltas")
log.info("      6. Tear down infrastructure\n")

try:
    log.info("Setting environment...")
    log.debug("     placeholder_ip: %s", str(os.environ["AVIATRIX_CONTROLLER_IP"]))
    log.debug("     placeholder_user: %s", str(os.environ["AVIATRIX_USERNAME"]))
    log.debug("     placeholder_pass: %s", str(os.environ["AVIATRIX_PASSWORD"]))
    avx_controller_ip = os.environ["avx_ip_2"]
    avx_controller_user = os.environ["avx_user_2"]
    avx_controller_pass = os.environ["avx_pass_2"]
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
        log.info("Creating AWS infrastructure...")
        tf.create_verify()
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*i)
        if i == 2:
            return_result("AWS_create_verify", False)
            sys.exit(1)
    else:
        return_result("AWS_create_verify", True)
        break


for j in range(3):
    try:
        log.debug("Verifying import functionality for AWS...")
        log.debug("     Importing AWS transit gateway...")
        tf.import_test("transit_gateway", "aws_segment_transit_gw")
        log.debug("     Importing Transit Segmentation Domains...")
        tf.import_test("segmentation_security_domain", "segment_dom_blue")
        tf.import_test("segmentation_security_domain", "segment_dom_green")
        log.debug("     Importing Segmentation Domain connection policy...")
        tf.import_test("segmentation_security_domain_connection_policy", "dom_blue_green_associate")
        log.debug("     Importing Segmentation Domain attachment assocations...")
        tf.import_test("segmentation_security_domain_association", "spoke_blue_associate")
        tf.import_test("segmentation_security_domain_association", "spoke_green_associate")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*j)
        if j == 2:
            return_result("AWS_import_test", False)
            sys.exit(1)
    else:
        return_result("AWS_import_test", True)
        break


for k in range(3):
    try:
        log.debug("Azure status : true...")
        tf.create_verify(varval="enable_azure=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*k)
        if k == 2:
            return_result("Azure_create_verify", False)
            sys.exit(1)
    else:
        return_result("Azure_create_verify", True)
        break


for l in range(3):
    try:
        log.debug("Verifying import functionality for Azure...")
        log.debug("     Importing Azure transit gateway...")
        tf.import_test("transit_gateway", "arm_segment_transit_gw", varval="enable_azure=true")
        log.debug("     Importing AWS-Azure transit gateway peering...")
        tf.import_test("transit_gateway_peering", "aws_arm_transit_peer", varval="enable_azure=true")
        log.debug("     Importing Azure Segmentation Domain attachment associations...")
        tf.import_test("segmentation_security_domain_association", "arm_spoke_blue_associate", varval="enable_azure=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*l)
        if l == 2:
            return_result("Azure_import_test", False)
            sys.exit(1)
    else:
        return_result("Azure_import_test", True)
        break


for m in range(3):
    try:
        log.debug("GCP status : true...")
        tf.create_verify(varval="enable_gcp=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*m)
        if m == 2:
            return_result("GCP_create_verify", False)
            sys.exit(1)
    else:
        return_result("GCP_create_verify", True)
        break


for n in range(3):
    try:
        log.debug("Verifying import functionality for GCP...")
        log.debug("     Importing GCP transit gateway...")
        tf.import_test("transit_gateway", "gcp_segment_transit_gw", varval="enable_gcp=true")
        log.debug("     Importing AWS-GCP transit gateway peering...")
        tf.import_test("transit_gateway_peering", "gcp_aws_transit_peer", varval="enable_gcp=true")
        log.debug("     Importing GCP Segmentation Domain attachment associations...")
        tf.import_test("segmentation_security_domain_association", "gcp_spoke_green_associate", varval="enable_gcp=true")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*n)
        if n == 2:
            return_result("GCP_import_test", False)
            sys.exit(1)
    else:
        return_result("GCP_import_test", True)
        break


for o in range(3):
    try:
        log.info("Verifying destroy functionality...")
        tf.destroy_test()
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*o)
        if o == 2:
            return_result("destroy_test", False)
            sys.exit(1)
    else:
        return_result("destroy_test", True)
        sys.exit(0)
