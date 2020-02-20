## For regression: Test case: test vpn gateway

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 223
}
resource "aviatrix_vpc" "aws_ldap_duo_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-ldap-duo-vpc"
  region                = "us-east-1"
}

resource "aviatrix_gateway" "aws_ldap_duo_gw" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  gw_name                 = "aws-ldap-duo-gw"
  vpc_id                  = aviatrix_vpc.aws_ldap_duo_vpc.vpc_id
  vpc_reg                 = aviatrix_vpc.aws_ldap_duo_vpc.region
  gw_size                 = "t2.micro"
  subnet                  = aviatrix_vpc.aws_ldap_duo_vpc.subnets.2.cidr

  vpn_access              = true
  max_vpn_conn            = 100
  vpn_cidr                = "192.168.44.0/24"
  enable_elb              = true
  elb_name                = "elb-aws-ldap-duo-gw"

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

output "aws_ldap_duo_gw_id" {
  value = aviatrix_gateway.aws_ldap_duo_gw.id
}
