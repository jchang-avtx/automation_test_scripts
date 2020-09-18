"""
run_gateway.py

Test case for AWS Gateway Terraform resource/ use-case

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
log.info("      2. Create AWS gateway (HA)")
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
    return_result("create_verify", False)
    sys.exit(1)
else:
    return_result("create_verify", True)


try:
    log.info("Verifying import functionality...")
    tf.import_test("gateway", "aws_gw_test_1")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("import_test", False)
    sys.exit(1)
else:
    return_result("import_test", True)


try:
    log.info("Verifying update functionality...")
    log.debug("     disableSNAT: Disabling single IP SNAT...")
    tf.update_test("disableSNAT")
    log.debug("     updateTagList: Updating gateway's tags...")
    tf.update_test("updateTagList")
    log.debug("     updateGWSize: Updating gateway's size...")
    tf.update_test("updateGWSize")
    log.debug("     updateHAGWSize: Updating HA gateway's size...")
    tf.update_test("updateHAGWSize")
    log.debug("     enableDNSServer: Enabling feature to remove the default DNS server, in favor of VPC DNS server configured in VPC DHCP option...")
    tf.update_test("enableDNSServer")
    log.debug("     updatePingInterval: Updating ping interval for gateway periodic ping...")
    tf.update_test("updatePingInterval")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("update_test", False)
    sys.exit(1)
else:
    return_result("update_test", True)


try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test()
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("destroy_test", False)
    sys.exit(1)
else:
    return_result("destroy_test", True)


log.info("Continuing to AWS GovCloud testing...")
log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: AWS GOVCLOUD GATEWAY")
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
    log.info("Verifying AWS GovCloud infrastructure...")
    tf.create_verify(varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("AWS_GovCloud_create_verify", False)
    sys.exit(1)
else:
    return_result("AWS_GovCloud_create_verify", True)


try:
    log.info("Verifying import functionality...")
    tf.import_test("gateway", "aws_gov_gw_test_1", varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("AWS_GovCloud_import_test", False)
    sys.exit(1)
else:
    return_result("AWS_GovCloud_import_test", True)


try:
    log.info("Verifying update functionality...")
    log.debug("     disableSNAT: Disabling single IP SNAT...")
    tf.create_verify(varfile="disableSNAT", varval="enable_gov=true")
    log.debug("     updateTagList: Updating gateway's tags...")
    tf.create_verify(varfile="updateTagList", varval="enable_gov=true")
    log.debug("     updateGWSize: Updating gateway's size...")
    tf.create_verify(varfile="updateGWSize", varval="enable_gov=true")
    log.debug("     updateHAGWSize: Updating HA gateway's size...")
    tf.create_verify(varfile="updateHAGWSize", varval="enable_gov=true")
    log.debug("     enableDNSServer: Enabling feature to remove the default DNS server, in favor of VPC DNS server configured in VPC DHCP option...")
    tf.create_verify(varfile="enableDNSServer", varval="enable_gov=true")
    log.debug("     updatePingInterval: Updating ping interval for gateway periodic ping...")
    tf.create_verify(varfile="updatePingInterval", varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("AWS_GovCloud_update_test", False)
    sys.exit(1)
else:
    return_result("AWS_GovCloud_update_test", True)


try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test(varval="enable_gov=true")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("AWS_GovCloud_destroy_test", False)
    sys.exit(1)
else:
    return_result("AWS_GovCloud_destroy_test", True)
