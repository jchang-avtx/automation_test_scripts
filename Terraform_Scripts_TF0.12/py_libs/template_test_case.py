"""
resource_subcategory.py

Template for test case for each Terraform resource/ use-case

- note various placeholders that must be updated:
    - filepath for terraform_fx.py
    - create/ import/ update/ destroy test functions and respective arguments
    - update "#" in "avx_ip_#", "avx_user_#", "avx_pass_#" accordingly
- place xxx.py in respective test_cases/xxx/ directory
"""

import os

import sys
print(sys.path)
sys.path.insert(1, '/file_path/aviatrix_terraform_regression/py_libs')
print(sys.path)
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

log.info("============================================================")
log.debug("RUNNING STAGE: " + str(os.path.split(os.getcwd())[1]).upper())
log.info("============================================================")
log.info("Steps to perform:")
log.info("      1. Some step")
log.info("      2. Some next step")

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
except:
    log.info("-------------------- RESULT --------------------")
    log.error("     Failed to properly set environment credentials!")
    sys.exit()

try:
    log.info("Creating infrastructure...")
    tf.create_verify()
except:
    log.info("-------------------- RESULT --------------------")
    log.error("     Infrastructure creation failed!")
    sys.exit()

try:
    log.info("Verifying import functionality...")
    tf.import_test(resource, name, varfile)
except:
    log.info("-------------------- RESULT --------------------")
    log.error("     Import test failed!")
    sys.exit()

try:
    log.info("Verifying update functionality...")
    tf.update_test(varfile)
except:
    log.info("-------------------- RESULT --------------------")
    log.error("     Update test cases failed!")
    sys.exit()

try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test()
except:
    log.info("-------------------- RESULT --------------------")
    log.error("     Destroy failed!")
    sys.exit()