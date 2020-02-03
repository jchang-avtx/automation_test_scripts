"""
run_gateway_vpn.py

Test case for gateway (AWS VPN SAML) Terraform resource/ use-case

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
log.info("      2. Create AWS GW (VPN-enabled), testing ELB and non-ELB")
log.info("      3. Perform terraform import to identify deltas")
log.info("      4. Perform update tests on various attributes")
log.info("      5. Tear down infrastructure\n")

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
    tf.import_test("gateway", "vpnGWunderELB")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     import_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      import_test(): PASS\n")


try:
    log.info("Verifying update functionality...")
    log.debug("     updateVPNCIDR: Updating the VPN CIDR for uses of accidental overlap with home network...")
    tf.update_test("updateVPNCIDR")
    log.debug("     updateSearchDomain: Updating list of domain names that will use the NameServers when specific name not in destination...")
    tf.update_test("updateSearchDomain")
    log.debug("     updateCIDRs: Updating list of destination CIDR ranges that will also go through the VPN tunnel...")
    tf.update_test("updateCIDRs")
    log.debug("     updateNameServers: Updating the list of DNS servers that VPN gateway will use to resolve domain names...")
    tf.update_test("updateNameServers")
    log.debug("     disableSingleAZHA: Disabling Single AZ HA option of the gateway...")
    tf.update_test("disableSingleAZHA")
    log.debug("     disableSplitTunnel: Disabling split_tunnel and all consequent attributes...")
    tf.update_test("disableSplitTunnel")
    log.debug("     updateMaxConn: Updating the maximum number of VPN users allowed to be connected to the gateway...")
    tf.update_test("updateMaxConn")
    log.debug("     disableVPNNAT: Disables VPN connection from using NAT when traffic leaves the gateway...")
    tf.update_test("disableVPNNAT")
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     update_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      update_test(): PASS\n")


try:
    log.info("Verifying destroy functionality...")
    tf.destroy_test()
except Exception as err:
    log.exception(str(err))
    log.info("-------------------- RESULT --------------------")
    log.error("     destroy_test(): FAIL\n")
    sys.exit(1)
log.info("-------------------- RESULT --------------------")
log.info("      destroy_test(): PASS\n")
