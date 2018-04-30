Aviatrix Encrypted Peering Reference Design
================================================================================


Description:
================================================================================

* The reference design assumes Aviatrix Controller is already launched and with admin account created.
  This reference design performs the following:
    + Launch two AWS VPCs (with different CIDRs) in the same or different regions
    + Launch one Ubuntu instance in each of these two VPCs
    + Create Aviatrix access account at Aviatrix Controller
    + Create one Aviatrix gateway in each of these two VPCs
    + Make encrypted peering between these two Aviatrix gateways
    + Send pings between the two Ubuntu instances and verify that pings should succeed
    + Remove encrypted peering created above
    + Send pings between the two Ubuntu instances and verify that pings should fail
    + Clean up testing environment by deleting gateways, Ubuntu instances and VPCs
    
* Edit user_config.json
{
  *"ucc_public_ip": "", 			#Aviatrix Controller public ip

  *"controller_username": "", 			#Aviatrix Controller user

  *"controller_password": "", 			#Aviatrix Controller password

  *"cloud_type": 1, 				#AWS cloud type-1

  *"aws_account_number": "",                    #AWS account credential

  *"aws_access_key_id": "",		        #AWS account credential

  *"aws_secret_access_key": "",			#AWS account credential

  *"region_vpc1": "us-east-1",		#VPC1 region

  *"region_vpc2": "us-west-1",		#VPC2 region

  "vpc1_tag": "test-vpc1",		#VPC1 name tag

  "vpc2_tag": "test-vpc2",		#VPC2 name tag

  "vpc1_cidr": "10.18.0.0/21",		#VPC1 CIDR

  "vpc2_cidr": "10.19.0.0/21",		#VPC2 CIDR

  "vpc1_subnet_cidr": "10.19.0.0/24",     #VPC1 subnet CIDR

  "vpc2_subnet_cidr": "10.18.0.0/24",	#VPC2 subnet CIDR

  *"account_name": "test_aws_account",          #Aviatrix access cloud account name

  *"account_password": "",                      #Aviatrix access cloud account password

  *"account_email": "",				#Aviatrix access cloud account email

  *"gateway1_name": "",				#Aviatrix Gateway1 name

  *"gateway2_name": "",             #Aviatrix Gateway2 name

  *"gateway1_size": "t2.micro",			#Aviatrix Gateway1 size

  *"gateway2_size": "t2.micro",			#Aviatrix Gateway2 size

}

* Enter sudo mode

* To create the reference design:

    $ python encrypted_peering.py user_config.json create

* To delete the reference design setup:

    $ python encrypted_peering.py user_config.json delete

* To run the whole suite

    $ python encrypted_peering.py user_config.json create-delete


