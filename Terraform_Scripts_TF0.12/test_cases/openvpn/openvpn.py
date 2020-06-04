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

def request_vpn_user(CID, api_endpoint_url, vpc_id):
    params = {
        "action": "get_vpn_ssl_ca_configuration",
        "CID": CID,
        "vpc_id": vpc_id,
        "username": "splunk-user",
        "lb_name": "elb-splunk-avx-vpn-gw"
    }
    request_call = requests.get(
        url = api_endpoint_url,
        params = params,
        verify = False
    )

    if "false" in str(request_call.text.encode('utf8')):
        raise Exception("RequestError: %s", str(request_call.text.encode('utf8')))
    else:
        return request_call.text.encode('utf8')

def download_vpn_user(CID, hostname_url, ovpn_filename):
    params = {
        "CID": CID,
        "filename": ovpn_filename
    }
    download_call = requests.get(
        url = hostname_url + "download",
        params = params,
        stream = True,
        verify = False
    )
    with open(ovpn_filename, "wb") as output_file_stream:
        for chunk in download_call.iter_content(chunk_size=256):
            if chunk:
                print("     chunk : 256" + str(type(chunk)))
                output_file_stream.write(chunk)

def run_ping_test(ping_list):
    transmitter.destination = ping_list
    # log.debug(transmitter.destination)
    transmitter.count = 2

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

    if packet_loss_rate > 0.0:
        raise Exception("PingFail: " + str(packet_loss_rate))

def upgrade_controller(CID, api_endpoint_url):
    data = {
        "action": "upgrade",
        "CID": CID,
    }
    upgrade_call = requests.post(
        url = api_endpoint_url,
        data = data,
        verify = False
    )

    if "false" in str(upgrade_call.text.encode('utf8')):
        raise Exception("UpgradeError: %s", str(upgrade_call.text.encode('utf8')))
    else:
        return upgrade_call.text.encode('utf8')

def main(argv):
    ping_list = argv[0]
    vpc_id = argv[1]
    # log.debug("ping_list : " + ping_list)
    log.debug("vpc_id : " + vpc_id)

    ## Use for REST API calls
    with open('credentials.tf.json') as cred:
        cred_dict = json.load(cred)
    controller_ip = cred_dict["variable"]["avx_ctrlr_ip"]["default"]
    controller_user = cred_dict["variable"]["avx_ctrlr_usr"]["default"]
    controller_password = cred_dict["variable"]["avx_ctrlr_pass"]["default"]

    hostname_url = "https://" + controller_ip + "/v1/"
    api_endpoint_url = hostname_url + "api"
    payload = {
        "action": "login",
        "username": controller_user,
        "password": controller_password
    }

    ## Program start
    log.info("\n")
    log.info("Verifying ping_list formatting...")
    try:
        ping_type_check = isinstance(ping_list, str)
        vpc_type_check = isinstance(vpc_id, str)

        if ping_type_check is False or vpc_type_check is False:
            raise Exception("TypeError")
    except:
        log.info("-------------------- RESULT --------------------")
        log.error("     arguments are NOT a string\n")
        sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("      ping_list : %s", ping_list)
        log.info("      vpc_id : %s", vpc_id)
        log.info("      ping_list is string\n")

    ## REST command to login
    log.info("\n")
    log.info("Attempting to log in to Controller...")
    try:
        log.debug("     api_endpoint_url : %s", api_endpoint_url)
        login_call = requests.post(
            url = api_endpoint_url,
            data = payload,
            verify = False
        )
        login_output = login_call.json()
        CID = login_output["CID"]
    except Exception as err:
        log.exception(str(err))
        log.error("Failed to log in to Controller: %s", controller_ip)
        sys.exit(1)
    else:
        log.info("Outputting JSON response below...")
        log.info("----------------------------------------")
        log.debug("     CID : %s", CID)
        log.debug(login_call.text.encode('utf8'))
        log.info("----------------------------------------")
        log.info("Controller login successful!\n")


    ## REST command to download .ovpn file
    # 1. get VPN config file name
    log.info("\n")
    log.info("Requesting VPN config file name for the user...")
    for i in range(3):
        try:
            result = request_vpn_user(CID, api_endpoint_url, vpc_id)
            dict = json.loads(result)
            ovpn_filename = dict["results"]
        except Exception as err:
            log.exception(str(err))
            log.info("Trying again in " + str(10 + 10*i) + " seconds...\n")
            time.sleep(10 + 10*i)
            if i == 2:
                log.error("Unable to request VPN file")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.debug("     ovpn_filename : %s", ovpn_filename)
            log.info("Successfully requested VPN config!\n")
            break


    # 2. download VPN config file
    log.info("\n")
    log.info("Downloading .ovpn file for the VPN user...")
    for i in range(3):
        try:
            download_vpn_user(CID, hostname_url, ovpn_filename)
        except Exception as err:
            log.exception(str(err))
            log.info("Trying again in " + str(10 + 10*i) + " seconds...\n")
            time.sleep(10 + 10*i)
            if i == 2:
                log.error("Failed to download .ovpn")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.info("Successfully downloaded .ovpn file!\n")
            break


    ## run OpenVPN client using .ovpn file
    log.info("\n")
    log.info("Running OpenVPN client to connect to ELB using downloaded .ovpn...")
    for i in range(3):
        try:
            subprocess.run('echo HelloWorld', shell=True)
        except Exception as err:
            log.exception(str(err))
            log.info("Trying to run OpenVPN client again in " + str(10 + 10*i) + " seconds...\n")
            time.sleep(10 + 10*i)
            if i == 2:
                log.error("Unable to run OpenVPN client")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.info("Successfully connected to ELB using .ovpn!\n")
            break

    ## send ping continuously
    # ping_cmd = 'ping -c 48 -i 10 ' + ping_list[i] # ~ 8 mins

    # can set for interval 10 second and specify packet count for total time
    # give option when setting up script for variable timing option
    # ping_cmd = 'ping -c 3 ' + ping_list
    log.info("\n")
    log.info("Trying to ping continuously for 1 minute to ensure connection...")
    for num_tries in range(3):
        try:
            run_ping_test(ping_list)
        except Exception as err:
            log.exception(err)
            log.info("Trying again in " + str(30 + 30*num_tries) + " seconds...\n")
            time.sleep(30 + 30*num_tries)
            if num_tries == 2:
                log.info("-------------------- RESULT --------------------")
                log.error("     Packet loss rate is over 0%")
                log.error("     ping_test(): FAIL\n")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.info("      ping_test(): PASS\n")
            break


    ## run REST command to call controller upgrade process
    log.info("\n")
    log.info("Upgrading Controller to latest...")
    try:
        upgrade_controller(CID, api_endpoint_url)
    except Exception as err:
        log.exception(err)
        log.error("Unable to upgrade controller")
        sys.exit(1)
    else:
        log.info("-------------------- RESULT --------------------")
        log.info("Successfully updated controller!\n")


    ## read the packet loss % . Should always be <3% packet loss
    log.info("\n")
    log.info("Trying to ping continuously for 1 minute after controller upgrade...")
    for num_tries in range(3):
        try:
            run_ping_test(ping_list)
        except Exception as err:
            log.exception(err)
            log.info("Trying again in " + str(30 + 30*num_tries) + " seconds...\n")
            time.sleep(30 + 30*num_tries)
            if num_tries == 2:
                log.info("-------------------- RESULT --------------------")
                log.error("     Packet loss rate is over 0%")
                log.error("     ping_test(): FAIL\n")
                sys.exit(1)
        else:
            log.info("-------------------- RESULT --------------------")
            log.info("      ping_test(): PASS\n")
            break


if __name__ == "__main__":
    main(sys.argv[1:]) # 0 is the program name in argv - take slice of args after prog
