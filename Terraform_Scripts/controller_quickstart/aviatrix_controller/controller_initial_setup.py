import requests
import sys
import time

if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('Usage: controller_initial_setup <public_ip> <private_ip> <admin_email> <admin_passwd> \n')
        exit (1)
    public_ip = sys.argv[1]
    private_ip = sys.argv[2]
    admin_email = sys.argv[3]
    admin_passwd = sys.argv[4]
    url = 'https://' + public_ip + "/v1/api"
    
    print("step 1: first time login")
    data = {
        "action": "login",
        "username": "admin",
        "password": private_ip
        #"password": admin_passwd
    }
    r = requests.get(url, params=data, verify=False)
    print("response: %s" % r.json())
    if r.json()['return'] != True:
        print('first time login failed!!')
        exit(1)
    cid = r.json()['CID']
    print("CID = %s" % cid)

    print("step 2: setup email address")
    data = {
        "action": "add_admin_email_addr",
        "admin_email": admin_email,
        "CID": cid
    }
    r = requests.get(url, params=data, verify=False)
    print("response: %s" % r.json())
    if r.json()['return'] != True:
        print('setup email address failed!!')
        exit(1)

    print("step 3: change admin password")
    data = {
        "action": "change_password",
        "account_name": "admin",
        "user_name": "admin",
        "old_password": private_ip,
        "password": admin_passwd,
        "CID": cid
    }
    r = requests.get(url, params=data, verify=False)
    print("response: %s" % r.json())
    if r.json()['return'] != True:
        print('change admin password failed!!')
        exit(1)

    print("step 4: login again with new password")
    data = {
        "action": "login",
        "username": "admin",
        "password": admin_passwd
    }
    r = requests.get(url, params=data, verify=False)
    print("response: %s" % r.json())
    if r.json()['return'] != True:
        print('login again with new password failed!!')
        exit(1)
    new_cid = r.json()['CID']
    print("CID = %s" % new_cid)

    print("step 5: initial setup")
    data = {
        "action": "initial_setup",
        "subaction": "run",
        "CID": new_cid
    }
    r = requests.post(url, data=data, verify=False)
    print("response: %s" % r.json())
    if r.json()['return'] == True:
        time.sleep(180)
    else:
        print('initial setup failed!!')
        exit(1)
    print("Congratulation! Your Aviatrix Controller is all set!!")
