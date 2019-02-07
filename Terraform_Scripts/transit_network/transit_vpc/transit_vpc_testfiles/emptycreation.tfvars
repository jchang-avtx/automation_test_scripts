# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis: id=8192 for issue with ha_subnet, ha_gw_size
## Please see Mantis: id=8209 for issues with refresh and update tests
## This file is also used to test Update test case;; See sections for Valid Input

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT
##############################################

# aviatrix_cloud_account_name = "PrimaryAccessAccount"
# aviatrix_cloud_type_aws = 1
# aviatrix_gateway_name = "testtransitGW1"
# # aviatrix_gateway_name = "updatedGatewayName" # use for Update test case
#
# aws_vpc_id = "vpc-abc123" # make sure this is the transitVPC; see specifications in the docs
# # aws_vpc_id = "vpc-def456" # input another valid vpc; uncomment for Update test case
# aws_region = "us-east-1"
# # aws_region = "us-west-1" # input another valid region; uncomment to use for Update test case
# aws_instance = "t2.micro"
# # aws_instance = "t2.small" # uncomment to use for Update test case
# aws_vpc_public_cidr = "123.0.0.0/24"
# # aws_vpc_public_cidr = "456.0.0.1/24" # input the valid cidr for the other valid vpc on line 21; uncomment to use for Update test case
#
# ## HA parameters
# aviatrix_ha_subnet = "123.0.0.0/24" # (optional) HA subnet. Setting to empty/unset will disable HA. Setting to valid subnet will create an HA gateway in the subnet
# # aviatrix_ha_subnet = "456.0.0.1/24" # input a valid subnet cidr for the other valid vpc on line 21; uncomment to use for Update test case
# aviatrix_ha_gw_size = "t2.micro"
# # aviatrix_ha_gw_size = "t2.small" # uncomment to use for Update test case
#
# tag_list = ["k1:v1","k2:v2"]
# # tag_list = ["k4:v4","k5:v5"] # uncomment to use for Update test case
# tgw_enable_hybrid = true
# # tgw_enable_hybrid = false # uncomment to use for Update test case

##############################################
## EMPTY / INVALID INPUT
##############################################

aviatrix_cloud_account_name = ""
# aviatrix_cloud_account_name = "as;dlfkj" # nonexistent account name
aviatrix_cloud_type_aws = 3 # 1 is for AWS. We only currently support 1
aviatrix_gateway_name = "" # empty gw name

aws_vpc_id = "" # empty
# aws_vpc_id = "vpc-123abc" # invalid vpc id
aws_region = "" # empty
# aws_region = "us-east-#" # invalid region
aws_instance = "" # empty
# aws_instance = "t2.invalid" # invalid instance size
aws_vpc_public_cidr = "" # empty
# aws_vpc_public_cidr = "1000000/100" # invalid subnet cidr

# HA parameters (OPTIONAL parameters must use invalid values, not empty .. bc theyre optional.)
# Blank optional parameter values usually default to just off, unless otherwise specified
aviatrix_ha_subnet = "asdf"# (optional) correctly catches incorrect input to not enable HA
aviatrix_ha_gw_size = "asdf"# (optional) HA gw size. Mandatory if HA is enabled (ex. "t2.micro")

tgw_enable_hybrid = "notaBoolean" # invalid: not a boolean input
# tgw_enable_hybrid = variable # invalid: not a boolean, is a variable type;; correctly fails
