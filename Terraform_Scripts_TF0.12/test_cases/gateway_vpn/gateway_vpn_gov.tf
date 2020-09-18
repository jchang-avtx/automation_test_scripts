## Test case: test vpn gateway (AWS GovCloud)

#################################################
# Infrastructure
#################################################
resource random_integer gov_vpc1_cidr_int {
  count = var.enable_gov ? 3 : 0
  min = 1
  max = 126
}
resource random_integer gov_vpc2_cidr_int {
  count = var.enable_gov ? 3 : 0
  min = 1
  max = 126
}

resource aviatrix_vpc aws_gov_vpn_gw_1_vpc {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, random_integer.gov_vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 256
  name                  = "aws-vpn-gw-1-vpc"
  region                = "us-gov-west-1"
}
resource aviatrix_vpc aws_gov_vpn_gw_2_vpc {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc2_cidr_int[0].result, random_integer.gov_vpc2_cidr_int[1].result, random_integer.gov_vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 256
  name                  = "aws-vpn-gw-2-vpc"
  region                = "us-gov-west-1"
}

#################################################
# VPN Gateways
#################################################
resource aviatrix_gateway gov_vpn_gw_1_under_elb {
  count = var.enable_gov ? 1 : 0
  cloud_type        = 256
  account_name      = "AWSGovRoot"
  gw_name           = "gov-vpn-gw-1-under-elb"
  vpc_id            = aviatrix_vpc.aws_gov_vpn_gw_1_vpc[0].vpc_id
  vpc_reg           = aviatrix_vpc.aws_gov_vpn_gw_1_vpc[0].region
  gw_size           = "t3.small"
  subnet            = aviatrix_vpc.aws_gov_vpn_gw_1_vpc[0].subnets.3.cidr

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
resource aviatrix_gateway gov_vpn_gw_2_under_elb {
  count = var.enable_gov ? 1 : 0
  cloud_type        = 256
  account_name      = "AWSGovRoot"
  gw_name           = "gov-vpn-gw-2-under-elb"
  vpc_id            = aviatrix_gateway.gov_vpn_gw_1_under_elb[0].vpc_id
  vpc_reg           = aviatrix_gateway.gov_vpn_gw_1_under_elb[0].vpc_reg
  gw_size           = "t3.small"
  subnet            = aviatrix_gateway.gov_vpn_gw_1_under_elb[0].subnet

  single_az_ha      = true
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.46.0/24" # must be non-overlapping CIDR
  vpn_protocol      = "UDP"
  enable_elb        = true
  enable_vpn_nat    = var.aviatrix_vpn_nat
  elb_name          = null # do not specify
  max_vpn_conn      = var.aviatrix_vpn_max_conn

  split_tunnel      = var.aviatrix_vpn_split_tunnel
  search_domains    = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.aviatrix_vpn_split_tunnel == false ? null : var.aviatrix_vpn_split_tunnel_name_servers_list

  saml_enabled      = true

}

## no elb in same region
resource aviatrix_gateway gov_vpn_gw_3_no_elb {
  count = var.enable_gov ? 1 : 0
  cloud_type        = 256
  account_name      = "AWSGovRoot"
  gw_name           = "gov-vpn-gw-3-no-elb"
  vpc_id            = aviatrix_vpc.aws_gov_vpn_gw_2_vpc[0].vpc_id
  vpc_reg           = aviatrix_vpc.aws_gov_vpn_gw_2_vpc[0].region
  gw_size           = "t3.small"
  subnet            = aviatrix_vpc.aws_gov_vpn_gw_2_vpc[0].subnets.3.cidr

  single_az_ha      = true
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.47.0/24"
  enable_elb        = false
  enable_vpn_nat    = var.aviatrix_vpn_nat

  max_vpn_conn  = 100
}

output gov_vpn_gw_1_under_elb_id {
  value = var.enable_gov ? aviatrix_gateway.gov_vpn_gw_1_under_elb[0].id : null
}
