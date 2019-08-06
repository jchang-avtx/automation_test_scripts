# Creates a VPN user in Aviatrix Controller

## VPN user needs VPN GW
resource "aviatrix_gateway" "vpn_gateway" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "testGW-VPN"

  vpc_id            = "vpc-0086065966b807866"
  vpc_reg           = "us-east-1"
  gw_size           = "t2.micro"
  subnet            = "10.0.0.0/24"

  vpn_access        = true
  saml_enabled      = true
  max_vpn_conn      = 100
  vpn_cidr          = "192.168.43.0/24"
  split_tunnel      = true
  enable_elb        = true
  elb_name          = "test-elb-name"
  enable_snat       = false
  allocate_new_eip  = true
}

resource "aviatrix_vpn_user" "test_vpn_user1" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy1"
  user_email        = var.vpn_user_email[0]
  saml_endpoint     = "saml_test_endpoint"
  depends_on        = ["aviatrix_gateway.vpn_gateway"]
}

resource "aviatrix_vpn_user" "test_vpn_user2" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy2"
  user_email        = var.vpn_user_email[1]
  saml_endpoint     = "saml_test_endpoint"
  depends_on        = ["aviatrix_gateway.vpn_gateway"]
}

resource "aviatrix_vpn_user" "test_vpn_user3" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy3"
  user_email        = var.vpn_user_email[2]
  saml_endpoint     = "saml_test_endpoint"
  depends_on        = ["aviatrix_gateway.vpn_gateway"]
}

resource "aviatrix_vpn_user" "test_vpn_user4" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy4"
  user_email        = var.vpn_user_email[3]
  saml_endpoint     = "saml_test_endpoint"
  depends_on        = ["aviatrix_gateway.vpn_gateway"]
}
