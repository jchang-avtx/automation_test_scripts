# initial creation

aws_vpc_id                      = "vpc-abc123" # VPC ID of the Avx VPN GW
aviatrix_gateway_name           = "gw1" # this is the Avx VPN GW, or the ELB ID if elb_enabled
aviatrix_vpn_user_name          = {
      "user1" = "testdummy1"
      "user2" = "testdummy2"
      "user3" = "testdummy3"
      "user4" = "testdummy4"
}
aviatrix_vpn_user_email         = {
      "email1" = "testdummy1@xyz.com"
      "email2" = "testdummy2@xyz.com"
      "email3" = "testdummy3@xyz.com"
      "email4" = "testdummy4@xyz.com"
}

## Comment out below if not testing SAML
aviatrix_vpn_user_saml          = ["saml_test_endpoint"]
