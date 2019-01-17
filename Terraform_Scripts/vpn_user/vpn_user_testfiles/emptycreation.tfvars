# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## There will be bugs with corrupt Terraform state; Please see Mantis: id=7985

## These credentials must be filled to test
aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

aws_vpc_id                      = "vpc-abcd1234"
aviatrix_gateway_name           = "gw1"
aviatrix_vpn_user_name          = {
      "user1" = "username1"
      "user2" = "username2"
      "user3" = "username3"
}
aviatrix_vpn_user_email         = {
      "email1" = "user1@xyz.com"
      "email2" = "user2@xyz.com"
      "email3" = "user3@xyz.com"
}

#########################
# INVALID INPUT BELOW
## You can also try inputting incorrect vpc id or gw name

# aws_vpc_id                      = ""
# aviatrix_gateway_name           = ""
# aviatrix_vpn_user_name          = {
#       "user1" = ""
#       "user2" = ""
#       "user3" = ""
# }
# aviatrix_vpn_user_email         = {
#       "email1" = ""
#       "email2" = ""
#       "email3" = ""
# }
