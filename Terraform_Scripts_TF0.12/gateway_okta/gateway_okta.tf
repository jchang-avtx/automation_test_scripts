## For regression: Test case: test vpn gateway (okta)

resource "aviatrix_gateway" "testGW3" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  gw_name                 = "testGW3"
  vpc_id                  = "vpc-ba3c12dd"
  vpc_reg                 = "us-west-1"
  gw_size                 = "t2.micro"
  subnet                  = "172.31.0.0/20"

  vpn_access              = true
  max_vpn_conn            = 100
  vpn_cidr                = "192.168.43.0/24"
  enable_elb              = true
  elb_name                = "elb-testgw3-vpn"

  split_tunnel            = true

  otp_mode                = 3
  okta_url                = var.aviatrix_vpn_okta_url
  okta_token              = var.aviatrix_vpn_okta_token
  okta_username_suffix    = var.aviatrix_vpn_okta_username_suffix

  allocate_new_eip        = true
}
