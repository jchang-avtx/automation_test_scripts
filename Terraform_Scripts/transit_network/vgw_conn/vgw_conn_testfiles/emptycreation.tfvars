# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis: id=8237 for issues with refresh tests
## This file is also used to test Update test case;; See sections for Valid Input

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT (for Update testing)
##############################################

tgw_vgw_conn_name         = "test_connection_tgw_vgw"
aviatrix_gateway_name     = "testtransitGW2" # input a valid transitGW name (existing)
aws_vpc_id                = "vpc-def456" # make sure this is the transitVPC#2's id
aws_vgw_id                = "vgw-2ndVGWID" # input a valid 2nd vgw id
bgp_local_as              = 200

##############################################
## EMPTY / INVALID INPUT
##############################################

## empty
# tgw_vgw_conn_name         = ""
# aviatrix_gateway_name     = ""
# aws_vpc_id                = ""
# aws_vgw_id                = ""
# bgp_local_as              =    # will ask for user input of ASN

## invalid inputs
# aws_vpc_id                = "invalidVPCID"
# aws_vgw_id                = "invalidVGWID"
# bgp_local_as              = "invalidASN" # will fail correctly asking for valid ASN
