# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## There will be bugs and Terraform crashing; Please see Mantis: id=7981, id=8119

## Additional test cases to consider:
## - special characters in profile_name (id=8205)

## These credentials must be filled to test
aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

##############################################
## VALID INPUTS
##############################################
aviatrix_vpn_profile_name       = "profileName1"
# aviatrix_vpn_profile_name       = "profile Name with SPACES"
aviatrix_vpn_profile_base_rule  = "deny_all"
aviatrix_vpn_profile_user_list  = ["user1"]

aviatrix_vpn_profile_action     = ["allow", "deny"] # can be referred to with [0] for allow, [1] for deny in vpn_user_profile.tf
aviatrix_vpn_profile_protocol   = ["all", "tcp", "udp", "icmp", "sctp", "rdp", "dccp"]
aviatrix_vpn_profile_port       = ["5544", "5555", "5566", "5577", "5588", "5599", "5600"]
aviatrix_vpn_profile_target     = ["10.0.0.0/32", "11.0.0.0/32", "12.0.0.0/32", "13.0.0.0/32", "14.0.0.0/32", "15.0.0.0/32", "16.0.0.0/32"]

##############################################
## EMPTY / INVALID INPUT
##############################################
# aviatrix_vpn_profile_user_list  = []
#
# aviatrix_vpn_profile_action     = ["",""] # can be referred to with [0] for allow, [1] for deny in vpn_user_profile.tf
# aviatrix_vpn_profile_protocol   = ["","","","","","",""]
# aviatrix_vpn_profile_port       = ["","","","","","",""]
# aviatrix_vpn_profile_target     = ["","","","","","",""]
