import sys
import os
import subprocess
import time

import json
import requests
requests.packages.urllib3.disable_warnings()

import logging
import logging.handlers

LOGLEVEL = logging.DEBUG
FORMAT = "%(asctime)s - %(levelname)s - %(message)s"
DATEFORMAT = "%d-%b-%y %H:%M:%S"
logging.basicConfig(level=LOGLEVEL,
                    format=FORMAT,
                    datefmt=DATEFORMAT,
                    handlers=[
                        logging.FileHandler(filename="openvpn.log"),
                        logging.StreamHandler()
                    ])
log = logging.getLogger(__name__)

def main(argv):
    ping_list = argv

    log.info("\n")
    log.info("Verifying ping_list formatting...")
    try:
        ping_type_check = isinstance(ping_list, str)

        if ping_type_check is False:
            raise Exception()
    except:
        log.info("-------------------- RESULT --------------------")
        log.error("     ping_list is NOT a string")
        sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.debug("     ping_list is string")

    # REST command to download .ovpn file

    # run OpenVPN client using .ovpn file

    # send ping continuously
    # ping_cmd = 'ping -c 48 -i 10 ' + ping_list[i]
    log.info("\n")
    log.info("Trying to ping continuously for 8 minutes")
    # can set for interval 10 second and specify packet count for total time
    # give option when setting up script for variable timing option
    ping_cmd = 'ping -c 3 ' + ping_list
    for num_tries in range(3):
        try:
            log.debug("ping_cmd:", str(ping_cmd))
            output = subprocess.getoutput(ping_cmd)
            log.debug(output)
        except subprocess.CalledProcessError as err:
            log.exception(err)
            time.sleep(30 + 30 * num_tries)
            if num_tries == 2:
                log.info("-------------------- RESULT --------------------")
                log.error("     ping_test(): FAIL\n")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.info("      ping_test(): PASS\n")
            sys.exit(0) # or break
    # run REST command to call controller upgrade process

    # read the packet loss % . Should always be <3% packet loss

if __name__ == "__main__":
    main(sys.argv[1]) # 0 is the program name in argv
