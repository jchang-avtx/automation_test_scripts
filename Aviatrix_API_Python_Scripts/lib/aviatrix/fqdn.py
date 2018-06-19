import sys
import paramiko
import requests
import traceback


PATH_TO_PROJECT_ROOT_DIR = "../"
sys.path.append((PATH_TO_PROJECT_ROOT_DIR))


requests.packages.urllib3.disable_warnings()


#######################################################################################################################
###########################################    FQDN Discovery    ######################################################
#######################################################################################################################


def start_fqdn_discovery(
        logger=None,
        url=None,
        CID=None,
        gateway_name=None,
        max_retry=10,
        log_indentation=""
        ):

    ### Required parameters
    data = {
        "action": "start_fqdn_discovery",
        "CID": CID,
        "gateway_name": gateway_name
    }

    ### Optional parameters
    pass


    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
        # END try-except
    # END for

    # logger.info("END: Aviatrix API: " + api_name)
    return response
# END create_XXX_avx_object_XXX()


def get_fqdn_discovery_result(
        logger=None,
        url=None,
        CID=None,
        gateway_name=None,
        max_retry=10,
        log_indentation=""
        ):

    ### Required parameters
    params = {
        "action": "get_fqdn_discovery_result",
        "CID": CID,
        "gateway_name": gateway_name
    }


    ### Optional parameters
    pass


    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=params, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
        # END try-except
    # END for

    # logger.info("END: Aviatrix API: " + api_name)
    return response
# END create_XXX_avx_object_XXX()


def stop_fqdn_discovery(
        logger=None,
        url=None,
        CID=None,
        gateway_name=None,
        max_retry=10,
        log_indentation=""
        ):

    ### Required parameters
    data = {
        "action": "stop_fqdn_discovery",
        "CID": CID,
        "gateway_name": gateway_name
    }


    ### Optional parameters
    pass


    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.post(url=url, data=data, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            logger.error(tracekback_msg)
        # END try-except
    # END for

    # logger.info("END: Aviatrix API: " + api_name)
    return response
# END create_XXX_avx_object_XXX()
