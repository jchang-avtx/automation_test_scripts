# Creates a VPN user in Aviatrix Controller

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "vpn_user_gw_vpc_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "vpn-user-gw-vpc-1"
  region                = "us-east-1"
}

## VPN user needs VPN GW
resource "aviatrix_gateway" "vpn_gateway" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "testGW-VPN"

  vpc_id            = aviatrix_vpc.vpn_user_gw_vpc_1.vpc_id
  vpc_reg           = aviatrix_vpc.vpn_user_gw_vpc_1.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.vpn_user_gw_vpc_1.subnets.6.cidr

  vpn_access        = true
  saml_enabled      = true
  max_vpn_conn      = 100
  vpn_cidr          = "192.168.43.0/24"
  split_tunnel      = true
  enable_elb        = true
  elb_name          = "test-elb-name"
  single_ip_snat    = false
  allocate_new_eip  = true
}

resource "aviatrix_vpn_user" "test_vpn_user1" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy1"
  user_email        = var.vpn_user_email[0]
  saml_endpoint     = "saml_test_endpoint"
}

resource "aviatrix_vpn_user" "test_vpn_user2" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy2"
  user_email        = var.vpn_user_email[1]
  saml_endpoint     = "saml_test_endpoint"
}

resource "aviatrix_vpn_user" "test_vpn_user3" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy3"
  user_email        = var.vpn_user_email[2]
  saml_endpoint     = "saml_test_endpoint"
}

resource "aviatrix_vpn_user" "test_vpn_user4" {
  vpc_id            = aviatrix_gateway.vpn_gateway.vpc_id
  gw_name           = aviatrix_gateway.vpn_gateway.elb_name
  user_name         = "testdummy4"
  user_email        = var.vpn_user_email[3]
  saml_endpoint     = "saml_test_endpoint"
}

#######################
## OUTPUTS
#######################

output "test_vpn_user1_id" {
  value = aviatrix_vpn_user.test_vpn_user1.id
}

output "test_vpn_user2_id" {
  value = aviatrix_vpn_user.test_vpn_user2.id
}

output "test_vpn_user3_id" {
  value = aviatrix_vpn_user.test_vpn_user3.id
}

output "test_vpn_user4_id" {
  value = aviatrix_vpn_user.test_vpn_user4.id
}
