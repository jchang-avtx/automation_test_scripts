# change gateway association for all users

## NOTE: gateway does not support update error
## however, changes will still go through as seen in terraform show
## no changes will be seen on GUI and thankfully, infrastructure is still managed and can be destroyed
## you can, however, change the gw on Controller, refresh on terraform and changes will go through

aws_vpc_id                      = "vpc-efgh5678"
aviatrix_gateway_name           = "gw2"
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
