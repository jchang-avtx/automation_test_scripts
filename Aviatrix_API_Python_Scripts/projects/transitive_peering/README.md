Aviatrix Transitive Peering Reference Design
================================================================================


Description:
================================================================================

* The reference design assumes Aviatrix Controller is already launched and with admin account created.
  This reference design performs the following:
    + Launch three AWS VPCs (with different CIDRs) in the same or different regions
    + Launch one Ubuntu instance in VPC1 and VPC3
    + Create Aviatrix access account at Aviatrix Controller
    + Create one Aviatrix gateway in each of these three VPCs
    + Make encrypted peering between gateway1 and gateway2
    + Make encrypted peering between gateway2 and gateway3
    + Create transitive peering with gateway1 as Source, gateway2 (NAT enabled) as Nexthop and VPC3 CIDR as destination
    + Send pings between the two Ubuntu instances and verify that pings from VPC1 to VPC3 should succeed
    + Remove transitive peering created above
    + Verify that pings from VPC1 to VPC3 should fail
    + Clean up testing environment by deleting encrypted peerings, gateways, Ubuntu instances and VPCs
    
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

  *"region_vpc3": "us-west-2",		#VPC3 region

  *"vpc1_tag": "test-vpc1",		#VPC1 name tag

  *"vpc2_tag": "test-vpc2",		#VPC2 name tag

  *"vpc3_tag": "test-vpc3",		#VPC3 name tag

  *"vpc1_cidr": "10.18.0.0/21",		#VPC1 CIDR

  *"vpc2_cidr": "10.19.0.0/21",		#VPC2 CIDR

  *"vpc3_cidr": "10.20.0.0/21",		#VPC3 CIDR

  *"vpc1_subnet_cidr": "10.18.0.0/24",     #VPC1 subnet CIDR

  *"vpc2_subnet_cidr": "10.19.0.0/24",	#VPC2 subnet CIDR

  *"vpc3_subnet_cidr": "10.20.0.0/24",	#VPC3 subnet CIDR

  *"account_name": "test_aws_account",          #Aviatrix access cloud account name

  *"account_password": "",                      #Aviatrix access cloud account password

  *"account_email": "",				#Aviatrix access cloud account email

  *"gateway1_name": "",				#Aviatrix Gateway1 name

  *"gateway2_name": "",             #Aviatrix Gateway2 name

  *"gateway3_name": "",             #Aviatrix Gateway3 name

  *"gateway1_size": "t2.micro",			#Aviatrix Gateway1 size

  *"gateway2_size": "t2.micro",			#Aviatrix Gateway2 size

  *"gateway3_size": "t2.micro",			#Aviatrix Gateway3 size

}

* Enter sudo mode

* To create the reference design:

    $ python encrypted_peering.py user_config.json create

* To delete the reference design setup:

    $ python encrypted_peering.py user_config.json delete

* To run the whole suite

    $ python encrypted_peering.py user_config.json create-delete


