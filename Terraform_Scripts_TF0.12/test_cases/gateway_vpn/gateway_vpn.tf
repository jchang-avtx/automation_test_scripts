## Test case: test vpn gateway

resource "aviatrix_gateway" "vpnGWunderELB" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "vpnGWunderELB"
  vpc_id            = "vpc-ba3c12dd"
  vpc_reg           = "us-west-1"
  gw_size           = "t2.micro"
  subnet            = "172.31.0.0/20"

  single_az_ha      = var.aviatrix_single_az_ha
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = var.aviatrix_vpn_cidr
  vpn_protocol      = "UDP"
  enable_elb        = true
  enable_vpn_nat    = var.aviatrix_vpn_nat
  elb_name          = "elb-vpngwunderelb"
  max_vpn_conn      = var.aviatrix_vpn_max_conn

  split_tunnel      = var.aviatrix_vpn_split_tunnel
  search_domains    = var.aviatrix_vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.aviatrix_vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.aviatrix_vpn_split_tunnel_name_servers_list

  saml_enabled      = true

}

## (11332) vpn gw needs to support workflow for multiple gw under same ELB
resource "aviatrix_gateway" "vpnGWunderELB2" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "vpnGWunderELB2"
  vpc_id            = aviatrix_gateway.vpnGWunderELB.vpc_id
  vpc_reg           = aviatrix_gateway.vpnGWunderELB.vpc_reg

  # v2
  gw_size           = "t2.micro"
  subnet            = aviatrix_gateway.vpnGWunderELB.subnet

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
  search_domains    = var.aviatrix_vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.aviatrix_vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.aviatrix_vpn_split_tunnel_name_servers_list

  saml_enabled      = true

}

## no elb
resource "aviatrix_gateway" "testcase3VPN" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "testcase3VPN"
  vpc_id            = "vpc-0e2e824ec2ab6787e"
  vpc_reg           = "us-west-1"
  gw_size           = "t2.micro"
  subnet            = "202.20.64.0/20"

  single_az_ha      = true
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.43.0/24"
  enable_elb        = false
  enable_vpn_nat    = var.aviatrix_vpn_nat

  max_vpn_conn  = 100
}

output "vpnGWunderELB_id" {
  value = aviatrix_gateway.vpnGWunderELB.id
}
