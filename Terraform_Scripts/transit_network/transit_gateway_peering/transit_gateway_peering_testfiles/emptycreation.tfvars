# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of emptyinvalid + valid input
## Please see Mantis: id=xxxx for reported refresh, update, and REST-API issues
## This file is also used to test Update test case;; See sections for Valid Input

##############################################
## VALID INPUT
##############################################
## THESE ARE THE VALUES YOU ARE CONCERNED WITH TESTING
# aviatrix_transit_gateway_1 = "transitGW1"
# aviatrix_transit_gateway_2 = "transitGW2"

## Should fail: Not allowed to update GW names
# aviatrix_transit_gateway_1 = "transitGW3"
# aviatrix_transit_gateway_2 = "transitGW4"

## DO NOT TOUCH VALUES BELOW
aviatrix_cloud_account_name = "PrimaryAccessAccount"
aviatrix_cloud_type_aws = 1
aviatrix_enable_nat = "yes"

aws_vpc_id = ["vpc-1234", "vpc-5678"] # make sure this is the transitVPC id; see specifications in the docs
aws_region = ["us-east-1", "us-west-1"]
aws_instance = "t2.micro"
aws_vpc_public_cidr = ["10.0.0.0/28", "11.0.0.0/28"]

tag_list = ["k1:v1","k2:v2"]
tgw_enable_hybrid = false # (optional) sign of readiness for TGW connection (ex. false)
tgw_enable_connected_transit = "yes" # (optional) specify connected transit status

##############################################
## EMPTY/ INVALID INPUTS
##############################################
# empty should fail because required
aviatrix_transit_gateway_1 = ""
aviatrix_transit_gateway_2 = ""

# invalid
# aviatrix_transit_gateway_1 = "invalidTransitGW1"
# aviatrix_transit_gateway_2 = "invalidTransitGW2"
