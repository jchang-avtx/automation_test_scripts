## Test case: test vpn gateway

#################################################
# Infrastructure
#################################################
resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 223
}
resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "aws_vpn_gw_1_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-vpn-gw-1-vpc"
  region                = "us-west-1"
}
resource "aviatrix_vpc" "aws_vpn_gw_2_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-vpn-gw-2-vpc"
  region                = "us-west-1"
}

#################################################
# VPN Gateways
#################################################
resource "aviatrix_gateway" "vpn_gw_1_under_elb" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "vpn-gw-1-under-elb"
  vpc_id            = aviatrix_vpc.aws_vpn_gw_1_vpc.vpc_id
  vpc_reg           = aviatrix_vpc.aws_vpn_gw_1_vpc.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.aws_vpn_gw_1_vpc.subnets.2.cidr

  single_az_ha      = var.aviatrix_single_az_ha
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = var.aviatrix_vpn_cidr
  vpn_protocol      = "UDP"
  enable_elb        = true
  enable_vpn_nat    = var.aviatrix_vpn_nat
  elb_name          = "elb-vpn-gw-1-under-elb"
  max_vpn_conn      = var.aviatrix_vpn_max_conn

  split_tunnel      = var.aviatrix_vpn_split_tunnel
  search_domains    = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_name_servers_list

  saml_enabled      = true

}

## (11332) vpn gw needs to support workflow for multiple gw under same ELB
resource "aviatrix_gateway" "vpn_gw_2_under_elb" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "vpn-gw-2-under-elb"
  vpc_id            = aviatrix_gateway.vpn_gw_1_under_elb.vpc_id
  vpc_reg           = aviatrix_gateway.vpn_gw_1_under_elb.vpc_reg

  # v2
  gw_size           = "t2.micro"
  subnet            = aviatrix_gateway.vpn_gw_1_under_elb.subnet

  single_az_ha      = true
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.45.0/24" # must be non-overlapping CIDR
  vpn_protocol      = "UDP"
  enable_elb        = true
  enable_vpn_nat    = true
  elb_name          = null # do not specify
  max_vpn_conn      = var.aviatrix_vpn_max_conn

  split_tunnel      = var.aviatrix_vpn_split_tunnel
  search_domains    = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_name_servers_list

  saml_enabled      = true

}

## no elb in same region
resource "aviatrix_gateway" "vpn_gw_3_no_elb" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "vpn-gw-3-no-elb"
  vpc_id            = aviatrix_vpc.aws_vpn_gw_2_vpc.vpc_id
  vpc_reg           = aviatrix_vpc.aws_vpn_gw_2_vpc.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.aws_vpn_gw_2_vpc.subnets.2.cidr

  single_az_ha      = true
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.43.0/24"
  enable_elb        = false
  enable_vpn_nat    = var.aviatrix_vpn_nat

  max_vpn_conn  = 100
}

output "vpn_gw_1_under_elb_id" {
  value = aviatrix_gateway.vpn_gw_1_under_elb.id
}
