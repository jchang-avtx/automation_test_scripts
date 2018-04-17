Aviatrix site2cloud reference design
================================================================================


Description:
================================================================================

* The reference design perform the following:
    + Create client AWS VPC and client instance
    + Create server AWS VPC and server instance
    + Setup Aviatrix access account
    + Launch cloud Aviatrix gateway in server VPC
    + Launch site Aviatrix gateway in client VPC
    + Get cloud Aviatrix gateway public IP
    + Get site Aviatrix gateway public IP
    + Build site2cloud from cloud Aviatrix gateway to site Aviatrix gateway and vice versa
    + Ping from cloud to site user instance
    
* Edit user_config.json (* is must specify field)
{
  *"ucc_public_ip": "",                         #Aviatrix Controller public ip
  *"controller_username": "",                   #Aviatrix Controller user
  *"controller_password": "",                   #Aviatrix Controller password
  "cloud_type": 1,                              #AWS cloud type-1, ARM cloud type-8
  *"aws_account_number": "",                    #AWS account credential
  *"aws_access_key_id": "",                     #AWS account credential
  *"aws_secret_access_key": "",                 #AWS account credential
  *"region_server": "us-east-1",                #Reference cloud VPC region
  *"region_client": "us-east-1",                #Reference site VPC region
  "vpc_server_tag": "test-vpc-server",          #Reference cloud VPC tag
  "vpc_client_tag": "test-vpc-client",          #Reference site VPC tag
  "vpc_client_cidr": "10.18.0.0/21",            #Reference cloud VPC cidr
  "vpc_server_cidr": "10.19.0.0/21",            #Reference site VPC cidr
  "vpc_server_subnet_cidr": "10.19.0.0/24",     #Reference cloud VPC subnet cidr
  "vpc_client_subnet_cidr": "10.18.0.0/24",     #Reference site VPC subnet cidr
  *"account_name": "test_aws_account",          #Aviatrix access cloud account name
  *"account_password": "",                      #Aviatrix access cloud account password
  *"account_email": "",                         #Aviatrix access cloud account email
  *"gateway_name": "",                          #Aviatrix cloud gateway name
  *"gateway_size": "t2.micro",                  #Aviatrix cloud gateway size
  *"gateway_site_name": "aviatrix-site", 	#Aviatrix site gateway name
  *"gateway_site_size": "t2.micro",		#Aviatrix site gateway size
  "connection_name_cloud": "cloud-site",	#site2cloud connection name from cloud
  "connection_name_site": "site-cloud",		#site2cloud connection name from site
  "connection_type_cloud": "avx",		#site2cloud connection type from cloud
  "connection_type_site": "avx",		#site2cloud connection type from site
  "s2c_psk": "Aviatrix",			#site2cloud connection psk
  "ha_enable": "false"				#site2cloud HA, enable-"true", disable-"false"
}

* Enter sudo mode 

* To create the reference design:
    $ python site2cloud.py user_config.json create

* To delete the reference design setup:

    $ python site2cloud.py user_config.json delete

* To run the whole suite

    $ python site2cloud.py user_config.json create-delete

