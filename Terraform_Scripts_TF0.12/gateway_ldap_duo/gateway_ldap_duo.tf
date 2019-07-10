## For regression: Test case: test vpn gateway

resource "aviatrix_gateway" "testGW4" {
  cloud_type              = 1
  account_name            = "AnthonyPrimaryAccess"
  gw_name                 = "testGW4"
  vpc_id                  = "vpc-0086065966b807866"
  vpc_reg                 = "us-east-1"
  vpc_size                = "t2.micro"
  vpc_net                 = "10.0.2.0/24"

  vpn_access              = "yes"
  max_vpn_conn            = 100
  vpn_cidr                = "192.168.44.0/24"
  enable_elb              = "yes"
  elb_name                = "elb-testgw4-vpn"

  split_tunnel            = "yes"

  otp_mode                = 2
  duo_integration_key     = var.aviatrix_vpn_duo_integration_key
  duo_secret_key          = var.aviatrix_vpn_duo_secret_key
  duo_api_hostname        = var.aviatrix_vpn_duo_api_hostname
  duo_push_mode           = var.aviatrix_vpn_duo_push_mode

  enable_ldap             = "yes"
  ldap_server             = var.aviatrix_vpn_ldap_server
  ldap_bind_dn            = var.aviatrix_vpn_ldap_bind_dn
  ldap_password           = var.aviatrix_vpn_ldap_password
  ldap_base_dn            = var.aviatrix_vpn_ldap_base_dn
  ldap_username_attribute = var.aviatrix_vpn_ldap_username_attribute

  allocate_new_eip        = "on"
}
