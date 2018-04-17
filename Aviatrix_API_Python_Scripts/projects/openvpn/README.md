Aviatrix OpenVPN reference design
================================================================================


Description:
================================================================================

* The reference design assumes Aviatrix Controller is already launched and admin account created.
  This reference design performs the following:
    + Create client AWS VPC and client instance
    + Create server AWS VPC and server instance
    + Setup Aviatrix access account
    + Launch Aviatrix VPN gateway
    + Add VPN user
    + Download VPN config file
    + Install openvpn client on client instance, copy VPN config file to client instance, load openvpn config file and perform ping test end to end
    
* Edit user_config.json
{
  *"ucc_public_ip": "", 			#Aviatrix Controller public ip

  *"controller_username": "", 			#Aviatrix Controller user

  *"controller_password": "", 			#Aviatrix Controller password

  "cloud_type": 1, 				#AWS cloud type-1, ARM cloud type-8

  *"aws_account_number": "",                    #AWS account credential

  *"aws_access_key_id": "",		        #AWS account credential

  *"aws_secret_access_key": "",			#AWS account credential

  *"region_server": "us-east-1",		#Reference VPN server VPC region

  *"region_client": "us-east-1",		#Reference VPN client VPC region

  "vpc_server_tag": "test-vpc-server",		#Reference VPN server VPC tag

  "vpc_client_tag": "test-vpc-client",		#Reference VPN client VPC tag

  "vpc_client_cidr": "10.18.0.0/21",		#Reference VPN server VPC cidr

  "vpc_server_cidr": "10.19.0.0/21",		#Reference VPN client VPC cidr

  "vpc_server_subnet_cidr": "10.19.0.0/24",     #Reference VPN server VPC subnet cidr

  "vpc_client_subnet_cidr": "10.18.0.0/24",	#Reference VPN client VPC subnet cidr

  *"account_name": "test_aws_account",          #Aviatrix access cloud account name


  *"account_password": "",                      #Aviatrix access cloud account password

  *"account_email": "",				#Aviatrix access cloud account email

  *"gateway_name": "",				#Aviatrix VPN gateway name

  *"gateway_size": "t2.micro",			#Aviatrix VPN gateway size

  *"vpn_username": "docker",			#Aviatrix VPN username

  *"vpn_user_email": "",			#Aviatrix VPN user email

  *"vpn_cidr": "192.168.43.0/24",		#VPN CIDR

  "duo_enable": false,                          #If DUO enabled-true, disabled-false

  "duo_api_hostname": "",			#DUO credential

  "duo_secret_key": "",				#DUO credential

  "duo_integration_key": "",			#DUO credential

  "elb_enable": "no",				#LB enabled-yes, disabled-no

  "elb_name": ""				#LB customised name,optional

}

* Enter sudo mode

* To create the reference design:

    $ python vpn.py user_config.json create

* To delete the reference design setup:

    $ python vpn.py user_config.json delete

* To run the whole suite

    $ python vpn.py user_config.json create-delete


