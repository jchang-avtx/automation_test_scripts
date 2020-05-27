import sys
import os
import subprocess
import time

import json
import requests
requests.packages.urllib3.disable_warnings()

import pingparsing
ping_parser = pingparsing.PingParsing()
transmitter = pingparsing.PingTransmitter()

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
    # log.debug("ping_list : " + ping_list)

    log.info("\n")
    log.info("Verifying ping_list formatting...")
    try:
        ping_type_check = isinstance(ping_list, str)

        if ping_type_check is False:
            raise Exception()
    except:
        log.info("-------------------- RESULT --------------------")
        log.error("     ping_list is NOT a string\n")
        sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      ping_list : " + ping_list)
        log.info("      ping_list is string\n")

    ## REST command to download .ovpn file

    ## run OpenVPN client using .ovpn file

    ## send ping continuously
    # ping_cmd = 'ping -c 48 -i 10 ' + ping_list[i] # ~ 8 mins

    # can set for interval 10 second and specify packet count for total time
    # give option when setting up script for variable timing option
    ping_cmd = 'ping -c 3 ' + ping_list

    transmitter.destination = ping_list
    # log.debug(transmitter.destination)
    transmitter.count = 2

    log.info("\n")
    log.info("Trying to ping continuously for 8 minutes...")
    for num_tries in range(3):
        try:
            result = transmitter.ping()
            string_dict = json.dumps(ping_parser.parse(result).as_dict())

            log.debug(json.dumps(ping_parser.parse(result).as_dict(), indent = 4))
            dict = json.loads(string_dict) # avoid messy handling of regex split of str
            # print(stringdict)
            # packet_loss_rate = re.split('"packet_loss_rate":', stringdict)
            # print(packet_loss_rate[1].split(",")[0])

            # log.debug(dict)
            packet_loss_rate = dict["packet_loss_rate"]
            # log.debug(packet_loss_rate)

            if packet_loss_rate is None:
                packet_loss_rate = 100.0

            if packet_loss_rate > 3.0:
                log.debug("     packet_loss_rate : " + str(packet_loss_rate))
                raise Exception("Packet loss rate is over 3%")
        except Exception as err:
            log.exception(err)
            log.info("Trying again in " + str(30 + 30*num_tries) + " seconds...\n")
            time.sleep(30 + 30*num_tries)
            if num_tries == 2:
                log.info("-------------------- RESULT --------------------")
                log.error("     ping_test(): FAIL\n")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.info("      packet_loss_rate : " + str(packet_loss_rate))
            log.info("      ping_test(): PASS\n")
            sys.exit(0) # or break

    ## run REST command to call controller upgrade process

    ## read the packet loss % . Should always be <3% packet loss

if __name__ == "__main__":
    main(sys.argv[1]) # 0 is the program name in argv
