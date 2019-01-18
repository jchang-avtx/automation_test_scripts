# Can be run after creation; changes emails in created users

## NOTE: email does not support update error
## emails will be changed on terraform show but will not on GUI
## infrastructure will still be managed and therefore can be destroyed still

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
      "email1" = "user4@xyz.com"
      "email2" = "user5@xyz.com"
      "email3" = "user6@xyz.com"
}
