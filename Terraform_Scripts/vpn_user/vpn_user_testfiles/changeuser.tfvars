# change user names;

## NOTE: Running this file will yield disassociating bug and will cause your profile to no longer be managed
## This consequently will not let you delete / manage this infrastructure through Terraform
## You must manually remove created infrastructure if you have ran terraform.tfvars previously.
## See Mantis: id = 7967

aws_vpc_id                      = "vpc-abcd1234"
aviatrix_gateway_name           = "gw1"
aviatrix_vpn_user_name          = {
      "user1" = "username4"
      "user2" = "username5"
      "user3" = "username6"
}
aviatrix_vpn_user_email         = {
      "email1" = "user1@xyz.com"
      "email2" = "user2@xyz.com"
      "email3" = "user3@xyz.com"
}
