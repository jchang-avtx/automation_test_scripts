"""
run_transit_gateway.py

Test case for AWS Transit Gateway (Insane HA) Terraform resource/ use-case

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

log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: " + str(os.path.split(os.getcwd())[1]).upper())
log.info("============================================================")
log.info("Steps to perform:")
log.info("      1. Set up environment variables/ credentials")
log.info("      2. Create AWS transit gateway (Insane HA)")
log.info("      3. Perform terraform import to identify deltas")
log.info("      4. Perform update tests on various attributes")
log.info("      5. Tear down infrastructure\n")

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


try:
    log.info("Creating infrastructure...")
    tf.create_verify()
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     create_verify(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      create_verify(): PASS\n")


try:
    log.info("Verifying import functionality...")
    tf.import_test("transit_gateway", "insane_transit_gw")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     import_test(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      import_test(): PASS\n")


try:
    log.info("Verifying update functionality...")
    log.debug("     enableSingleAZHA: Enabling single AZHA feature...")
    tf.update_test("enableSingleAZHA")
    log.debug("     switchConnectedTransit: Disabling spokes from running traffic to other spokes via transit gateway...")
    tf.update_test("switchConnectedTransit")
    log.debug("     disableHybrid: Disabling transit gateway from being used in AWS TGW solution...")
    tf.update_test("disableHybrid")
    log.debug("     updateGWSize: Updating gateway's size...")
    tf.update_test("updateGWSize")
    log.debug("     updateHAGWSize: Updating HA gateway's size...")
    tf.update_test("updateHAGWSize")
    log.debug("     enableDNSServer: Enabling feature to remove the default DNS server, in favor of VPC DNS server configured in VPC DHCP option...")
    tf.update_test("enableDNSServer")
    log.debug("     updateCustomRoutes: Updating list of CIDRs to propagate to for spoke VPC...")
    tf.update_test("updateCustomRoutes")
    log.debug("     updateFilterRoutes: Updating list of unwanted CIDRs to filter on-prem to spoke VPC...")
    tf.update_test("updateFilterRoutes")
    log.debug("     updateExcludeAdvertiseRoutes: Updating list of VPC CIDRs to exclude from being advertised to on-prem...")
    tf.update_test("updateExcludeAdvertiseRoutes")
    log.debug("     updateLearnedCIDRApproval: Disable approval requirement for Learned CIDRs...")
    tf.update_test("updateLearnedCIDRApproval")
    log.debug("     updateBGP: Update the BGP-related parameters BGP ECMP and polling time...")
    tf.update_test("updateBGP")
    log.debug("     updateAS: Update AS-related parameters local ASN and prepending AS path list...")
    tf.update_test("updateAS")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     update_test(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      update_test(): PASS\n")


try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test()
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     destroy_test(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      destroy_test(): PASS\n")


time.sleep(60)
log.info("Continuing to AWS GovCloud testing...")
log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: AWS GOVCLOUD TRANSIT GATEWAY")
log.info("============================================================")

try:
    log.info("Setting AWS GovCloud environment...")
    aws_gov_access_key = os.environ["aws_gov_access_key"]
    aws_gov_secret_key = os.environ["aws_gov_secret_key"]
    log.info("Setting new variable values as follows...")
    log.debug("     aws_gov_access_key: %s", aws_gov_access_key)
    log.debug("     aws_gov_secret_key: %s", aws_gov_secret_key)
    os.environ["AWS_ACCESS_KEY_ID"] = aws_gov_access_key
    os.environ["AWS_SECRET_ACCESS_KEY"] = aws_gov_secret_key
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     Failed to properly set AWS GovCloud environment credentials!")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      Set AWS GovCloud environment credentials: PASS\n")


try:
    log.info("Creating infrastructure...")
    tf.create_verify(varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     AWS_GovCloud_create_verify(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      AWS_GovCloud_create_verify(): PASS\n")


try:
    log.info("Verifying import functionality...")
    tf.import_test("transit_gateway", "gov_insane_transit_gw", varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     AWS_GovCloud_import_test(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      AWS_GovCloud_import_test(): PASS\n")


try:
    log.info("Verifying update functionality...")
    log.debug("     enableSingleAZHA: Enabling single AZHA feature...")
    tf.create_verify(varfile="enableSingleAZHA", varval="enable_gov=true")
    log.debug("     switchConnectedTransit: Disabling spokes from running traffic to other spokes via transit gateway...")
    tf.create_verify(varfile="switchConnectedTransit", varval="enable_gov=true")
    log.debug("     disableHybrid: Disabling transit gateway from being used in AWS TGW solution...")
    tf.create_verify(varfile="disableHybrid", varval="enable_gov=true")
    log.debug("     updateGWSize: Updating gateway's size...")
    tf.create_verify(varfile="updateGWSize", varval="enable_gov=true")
    log.debug("     updateHAGWSize: Updating HA gateway's size...")
    tf.create_verify(varfile="updateHAGWSize", varval="enable_gov=true")
    log.debug("     enableDNSServer: Enabling feature to remove the default DNS server, in favor of VPC DNS server configured in VPC DHCP option...")
    tf.create_verify(varfile="enableDNSServer", varval="enable_gov=true")
    log.debug("     updateCustomRoutes: Updating list of CIDRs to propagate to for spoke VPC...")
    tf.create_verify(varfile="updateCustomRoutes", varval="enable_gov=true")
    log.debug("     updateFilterRoutes: Updating list of unwanted CIDRs to filter on-prem to spoke VPC...")
    tf.create_verify(varfile="updateFilterRoutes", varval="enable_gov=true")
    log.debug("     updateExcludeAdvertiseRoutes: Updating list of VPC CIDRs to exclude from being advertised to on-prem...")
    tf.create_verify(varfile="updateExcludeAdvertiseRoutes", varval="enable_gov=true")
    log.debug("     updateLearnedCIDRApproval: Disable approval requirement for Learned CIDRs...")
    tf.create_verify(varfile="updateLearnedCIDRApproval", varval="enable_gov=true")
    log.debug("     updateBGP: Update the BGP-related parameters BGP ECMP and polling time...")
    tf.create_verify(varfile="updateBGP", varval="enable_gov=true")
    log.debug("     updateAS: Update AS-related parameters local ASN and prepending AS path list...")
    tf.create_verify(varfile="updateAS", varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     AWS_GovCloud_update_test(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      AWS_GovCloud_update_test(): PASS\n")


try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test(varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    log.info("-------------------- RESULT --------------------")
    log.error("     AWS_GovCloud_destroy_test(): FAIL\n")
    sys.exit(1)
else:
    log.info("-------------------- RESULT --------------------")
    log.info("      AWS_GovCloud_destroy_test(): PASS\n")
