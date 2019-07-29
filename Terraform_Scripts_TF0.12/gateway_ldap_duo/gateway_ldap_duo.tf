## For regression: Test case: test vpn gateway

resource "aviatrix_gateway" "testGW4" {
  cloud_type              = 1
  account_name            = "AnthonyPrimaryAccess"
  gw_name                 = "testGW4"
  vpc_id                  = "vpc-0086065966b807866"
  vpc_reg                 = "us-east-1"
  gw_size                 = "t2.micro"
  subnet                  = "10.0.2.0/24"

  vpn_access              = true
  max_vpn_conn            = 100
  vpn_cidr                = "192.168.44.0/24"
  enable_elb              = true
  elb_name                = "elb-testgw4-vpn"

  split_tunnel            = true

  otp_mode                = 2
  duo_integration_key     = var.aviatrix_vpn_duo_integration_key
  duo_secret_key          = var.aviatrix_vpn_duo_secret_key
  duo_api_hostname        = var.aviatrix_vpn_duo_api_hostname
  duo_push_mode           = var.aviatrix_vpn_duo_push_mode

  enable_ldap             = true
  ldap_server             = var.aviatrix_vpn_ldap_server
  ldap_bind_dn            = var.aviatrix_vpn_ldap_bind_dn
  ldap_password           = var.aviatrix_vpn_ldap_password
  ldap_base_dn            = var.aviatrix_vpn_ldap_base_dn
  ldap_username_attribute = var.aviatrix_vpn_ldap_username_attribute

  allocate_new_eip        = true
}
