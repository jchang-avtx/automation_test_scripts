"""
run_s2c.py

Test case for S2C configuration for both Unmapped and Mapped

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
log.info("      2. Create S2C configuration using both mapped and unmapped connections")
log.info("      3. Perform terraform import to identify deltas")
log.info("      4. Tear down part of infrastructure to reuse for Mapped connection test")
log.info("      5. Create mapped connections")
log.info("      6. Perform teraform import tests")
log.info("      7. Tear down infrastructure\n")

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
log.info("-------------------- RESULT --------------------")
log.info("      Set environment credentials: PASS\n")


try:
    log.info("Creating infrastructure...")
    tf.create_verify()
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     create_verify(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      create_verify(): PASS\n")


try:
    log.info("Verifying import functionality...")
    log.debug("     Importing S2C unmapped configuration...")
    tf.import_test("site2cloud", "s2c_test2")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     import_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      import_test(): PASS\n")


log.debug("Sleeping for 2 minutes to wait for infrastructure to be up...")
time.sleep(120)


try:
    log.info("Verifying destroy functionality for Unmapped...")
    tf.destroy_target("site2cloud", "s2c_test")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     destroy_target(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      destroy_target(): PASS\n")


log.info("Continuing to site2cloud: Mapped...")
log.info("\n")
log.info("============================================================")
log.debug("RUNNING STAGE: SITE2CLOUD_MAPPED")
log.info("============================================================")
try:
    log.debug("Enabling custom algorithms and creating new S2C connections as Mapped...")
    tf.update_test("enableCustomAlg")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     update_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      update_test(): PASS\n")


try:
    log.info("Verifying import functionality...")
    log.debug("     Importing S2C mapped configuration...")
    tf.import_test("site2cloud", "s2c_test2", "enableCustomAlg")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     import_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      import_test(): PASS\n")


log.debug("Sleeping for 2 minutes to wait for infrastructure to be up...")
time.sleep(120)


try:
    log.info("Verifying destroy functionality for Mapped...")
    tf.destroy_test()
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     destroy_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      destroy_test(): PASS\n")
