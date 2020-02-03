"""
run_vpn_profile.py

Test case for Aviatrix VPN profile Terraform resource/ use-case

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
                        logging.FileHandler(filename=TIMESTR + "_regression_result.log"),
                        logging.StreamHandler()
                    ])
log = logging.getLogger()

log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: " + str(os.path.split(os.getcwd())[1]).upper())
log.info("============================================================")
log.info("Steps to perform:")
log.info("      1. Set up environment variables/ credentials")
log.info("      2. Create Aviatrix VPN profile")
log.info("      3. Perform terraform import to identify deltas")
log.info("      4. Perform update tests to test profile-based rules")
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
    sys.exit()
log.info("-------------------- RESULT --------------------")
log.info("      Set environment credentials: PASS\n")


try:
    log.info("Creating infrastructure...")
    tf.create_verify()
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     create_verify(): FAIL\n")
    sys.exit()
log.info("-------------------- RESULT --------------------")
log.info("      create_verify(): PASS\n")


try:
    log.info("Verifying import functionality...")
    log.debug("     Importing VPN profile 1...")
    tf.import_test("vpn_profile", "test_profile1")
    log.debug("     Importing VPN profile 2...")
    tf.import_test("vpn_profile", "test_profile2")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     import_test(): FAIL\n")
    sys.exit()
log.info("-------------------- RESULT --------------------")
log.info("      import_test(): PASS\n")


try:
    log.info("Verifying update functionality...")
    log.debug("     switchAction: Updating rules for allow/deny policy...")
    tf.update_test("switchAction")
    log.debug("     switchPort: Updating ruless' allowed/denied port...")
    tf.update_test("switchPort")
    log.debug("     switchProtocol: Updating rules' allowed/denied protocol...")
    tf.update_test("switchProtocol")
    log.debug("     switchTarget: Updating rules' target IP/CIDR...")
    tf.update_test("switchTarget")
    log.debug("     removeUser: Detach user from VPN profile...")
    tf.update_test("removeUser")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     update_test(): FAIL\n")
    sys.exit()
log.info("-------------------- RESULT --------------------")
log.info("      update_test(): PASS\n")


try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test()
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     destroy_test(): FAIL\n")
    sys.exit()
log.info("-------------------- RESULT --------------------")
log.info("      destroy_test(): PASS\n")
