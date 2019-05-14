# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of emptyinvalid + valid input
## Please see Mantis: id=8195 for reported refresh, update, and REST-API issues
## This file is also used to test Update test case;; See sections for Valid Input

##############################################
## VALID INPUT
##############################################

# aviatrix_cloud_account_name = "PrimaryAccessAccount"
# aviatrix_cloud_type_aws = 1
# aviatrix_gateway_name = "spoke-gw-01"
# # aviatrix_gateway_name = "updatedGatewayName" # use for Update test case
#
# aws_vpc_id = "vpc-abc123"
# # aws_vpc_id = "vpc-def456" # input another valid vpc; uncomment to use for Update test case
# aws_region = "us-east-1"
# # aws_region = "us-west-1" # input another valid region; uncomment to use for Update test case
# aws_instance = "t2.micro"
# # aws_instance = "t2.small" # use for Update test case
# aws_vpc_public_cidr = "123.0.0.0/24"
# # aws_vpc_public_cidr = "456.0.0.0/24" # input the valid cidr for the other valid vpc on line 20; uncomment to use for Update test case
#
# aviatrix_ha_subnet = "123.0.0.0/24"
# # aviatrix_ha_subnet = "456.0.0.0/24" # input a valid subnet cidr for the other valid vpc on line 20; uncommment to use for Update test case
# aviatrix_ha_gw_size = "t2.micro"
# # aviatrix_ha_gw_size = "t2.small" # uncomment to use for Update test case
# aviatrix_enable_nat = "yes"
# # aviatrix_enable_nat = "no" # uncomment to use for Update test case
#
# aviatrix_transit_gw = "transitGW1" # seems to be an option only when you have a transit_gw to specify
# tag_list = ["k1:v1","k2:v2"]
# # tag_list = ["k1:v1","k3:v3"] # uncomment to use for Update test case

##############################################
## EMPTY / INVALID INPUT
##############################################

aviatrix_cloud_account_name = "" # empty cloud account
# aviatrix_cloud_account_name = "invalidAccountName"
aviatrix_cloud_type_aws = 3 # invalid cloud type
aviatrix_gateway_name = "" # empty gateway name
# aviatrix_gateway_name = "invalidGatewayName"

aws_vpc_id = ""
# aws_vpc_id = "vpc-123" # invalid VPC
aws_region = ""
# aws_region = "invalidRegion"
aws_instance = ""
# aws_instance = "t2.MASSIVE" # invalid instance type
aws_vpc_public_cidr = ""
# aws_vpc_public_cidr = "9999/33" # invalid CIDR syntax

aviatrix_ha_subnet = "9999/33" # invalid HA_subnet since empty just assumes no.
aviatrix_ha_gw_size = ""
# aviatrix_ha_gw_size = "t2.MASSIVE" # invalid instance type
aviatrix_enable_nat = "YEAH" # invalid enableNAT because empty assumes no

aviatrix_transit_gw = "invalidTransitGW" # seems to be an option only when you have a transit_gw to specify
tag_list = [""]
