"""
run_geo_vpn.py

Test case for geo_vpn Terraform resource/ use-case

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
log.info("      2. Create Geo VPN and Route53 setup")
log.info("      3. Perform terraform import to identify deltas")
log.info("      4. Tear down infrastructure\n")

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
    log.debug("     Importing Geo VPN...")
    tf.import_test("geo_vpn", "test_geo_vpn")
    log.debug("     Importing Geo VPN user...")
    tf.import_test("vpn_user", "geo_vpn_user")
except tf.subprocess.CalledProcessError as err:
    log.exception(err.stderr.decode())
    return_result("import_test", False)
    sys.exit(1)
else:
    return_result("import_test", True)


log.info(str(os.path.split(os.getcwd())[1]).upper() + " does not support update functionality...")
log.info("Testing support of update functionality of ELB/ GeoVPN settings - Mantis (13570)... ")
for i in range(3):
    try:
        log.debug("     updateVPN: Updating the ELB/ GeoVPN settings by updating all ELB's VPN settings simultaneously...")
        tf.update_test("updateVPN")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*i)
        if i == 2:
            return_result("update_test", False)
            sys.exit(1)
    else:
        return_result("update_test", True)
        break


log.info("Verifying destroy functionality...")
for i in range(3):
    try:
        log.debug("     destroy_target() one of the ELB gateway first...") # Mantis (13255)
        tf.destroy_target("gateway", "r53_gw_3")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*i)
        if i == 2:
            return_result("destroy_test", False)
            sys.exit(1)
    else:
        log.debug("Sleeping for 1 minute to wait for gateway clean-up...")
        time.sleep(60)
        break

for j in range(3):
    try:
        log.debug("     destroy_target() the other ELB gateway...")
        tf.destroy_target("gateway", "r53_gw_1")
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*j)
        if j == 2:
            return_result("destroy_test", False)
            sys.exit(1)
    else:
        log.debug("Sleeping for 1 minute...")
        time.sleep(60)
        break

for k in range(3):
    try:
        log.debug("     Now running destroy_test() to finish clean-up...")
        tf.destroy_test()
    except tf.subprocess.CalledProcessError as err:
        log.exception(err.stderr.decode())
        time.sleep(60 + 60*k)
        if k == 2:
            return_result("destroy_test", False)
            sys.exit(1)
    else:
        return_result("destroy_test", True)
        sys.exit(0)
