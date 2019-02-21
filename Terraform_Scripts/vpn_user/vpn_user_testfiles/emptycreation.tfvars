# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## There will be bugs with corrupt Terraform state; Please see Mantis: id=7985

## These credentials must be filled to test
aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

################################################
## VALID INPUT
################################################
# aws_vpc_id                      = "vpc-abc123" # VPC ID of the Avx VPN GW
# aviatrix_gateway_name           = "gw1" # this is the Avx VPN GW, or the ELB ID if elb_enabled
# aviatrix_vpn_user_name          = {
#       "user1" = "testdummy1"
#       "user2" = "testdummy2"
#       "user3" = "testdummy3"
#       "user4" = "testdummy4"
# }
# aviatrix_vpn_user_email         = {
#       "email1" = "testdavtx1@gmail.com"
#       "email2" = "testdavtx2@gmail.com"
#       "email3" = "testdavtx3@gmail.com"
#       "email4" = "testdavtx4@gmail.com"
# }

# aviatrix_vpn_user_saml          = ["saml_test_endpoint"]

################################################
# INVALID INPUT BELOW
################################################
## You can also try inputting incorrect vpc id or gw name

# empty
aws_vpc_id                      = ""
aviatrix_gateway_name           = ""

# invalid
aws_vpc_id                      = "vpc-notReal" # invalid
aviatrix_gateway_name           = "notRealGWName" # invalid

aviatrix_vpn_user_name          = {
      "user1" = ""
      "user2" = ""
      "user3" = ""
      "user4" = ""
}
aviatrix_vpn_user_email         = {
      "email1" = ""
      "email2" = ""
      "email3" = ""
      "email4" = ""
}

aviatrix_vpn_user_saml          = [" "] # invalid "<" error
# aviatrix_vpn_user_saml          = [""] # empty list works fine
