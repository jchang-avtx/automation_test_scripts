import requests
from lib.aviatrix.initial_setup import login
import threading
import time
import traceback



def my_login(id=None):
    url = "https://13.57.123.123/v1/api"
    max_retry = 5

    ### Required parameters
    payload = {
        "action": "login",
        "username": "admin",
        "password": "Oij54138!"
    }

    ### Call Aviatrix API (with max retry)
    for i in range(max_retry):
        try:
            # Send the GET/POST RESTful API request
            response = requests.get(url=url, params=payload, verify=False)

            if response.status_code == 200:
                # IF status_code is 200 meaning server has responded, then break out of retry loop
                py_dict = response.json()
                print(str(id) + "    " + str(py_dict))
                break

        except Exception as e:
            tracekback_msg = traceback.format_exc()
            print(tracekback_msg)
        # END try-except
    # END for

    # logger.info("END: Aviatrix API: " + api_name)
    return response



def yo(i):
    while True:
        my_login(i)




for i in range(3):
    t = threading.Thread(target=yo, args=[i])
    t.start()


# params = {
#     "action": "login",
#     "username": "admin",
#     "password": password
# }
# id = 1
# response = requests.get(url=url, params=params, verify=False)
# py_dict = response.json()
# print("\n")
# print(str(id) + "    " + str(py_dict))

