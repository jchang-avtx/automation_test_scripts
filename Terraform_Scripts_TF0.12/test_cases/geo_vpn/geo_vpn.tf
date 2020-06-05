# 1 GW + ELB, another GW under the same VPC (and ELB)
resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "aviatrix_vpc" "r53_vpc_1" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-2"
  name                  = "r53-vpc-1"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}

data "aviatrix_vpc" "r53_vpc_1" {
  name = aviatrix_vpc.r53_vpc_1.name
}

resource "aviatrix_gateway" "r53_gw_1" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "r53-gw-1"
  vpc_id            = aviatrix_vpc.r53_vpc_1.vpc_id
  vpc_reg           = aviatrix_vpc.r53_vpc_1.region
  gw_size           = "t2.micro"
  subnet            = data.aviatrix_vpc.r53_vpc_1.public_subnets.0.cidr

  single_az_ha      = false
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.43.0/24"
  enable_elb        = true
  enable_vpn_nat    = var.vpn_nat_status # true
  elb_name          = "elb-r53-1"
  max_vpn_conn      = var.max_vpn_conn # 100

  split_tunnel      = var.vpn_split_tunnel
  search_domains    = var.vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.vpn_split_tunnel_name_servers_list
}

resource "aviatrix_gateway" "r53_gw_2" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "r53-gw-2"
  vpc_id            = aviatrix_vpc.r53_vpc_1.vpc_id
  vpc_reg           = aviatrix_vpc.r53_vpc_1.region
  gw_size           = "t2.micro"
  subnet            = data.aviatrix_vpc.r53_vpc_1.public_subnets.0.cidr

  single_az_ha      = false
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.44.0/24"
  enable_elb        = true
  enable_vpn_nat    = var.vpn_nat_status # true
  elb_name          = aviatrix_gateway.r53_gw_1.elb_name # if gw in same VPC with ELB, do not set name (only on GUI)
  max_vpn_conn      = var.max_vpn_conn # 100

  split_tunnel      = var.vpn_split_tunnel
  search_domains    = var.vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.vpn_split_tunnel_name_servers_list
}

################################################################
resource "random_integer" "vpc3_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "aviatrix_vpc" "r53_vpc_3" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "r53-vpc-3"
  cidr                  = join(".", [random_integer.vpc3_cidr_int[0].result, random_integer.vpc3_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}

data "aviatrix_vpc" "r53_vpc_3" {
  name = aviatrix_vpc.r53_vpc_3.name
}

resource "aviatrix_gateway" "r53_gw_3" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "r53-gw-3"
  vpc_id            = aviatrix_vpc.r53_vpc_3.vpc_id
  vpc_reg           = aviatrix_vpc.r53_vpc_3.region
  gw_size           = "t2.micro"
  subnet            = data.aviatrix_vpc.r53_vpc_3.public_subnets.0.cidr

  single_az_ha      = false
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.45.0/24"
  enable_elb        = true
  enable_vpn_nat    = var.vpn_nat_status # true
  elb_name          = "elb-r53-2"
  max_vpn_conn      = var.max_vpn_conn # 100

  split_tunnel      = var.vpn_split_tunnel
  search_domains    = var.vpn_split_tunnel_search_domain_list
  additional_cidrs  = var.vpn_split_tunnel_additional_cidrs_list
  name_servers      = var.vpn_split_tunnel_name_servers_list
}

################################################################
resource "aviatrix_geo_vpn" "test_geo_vpn" {
  account_name    = "AWSAccess"
  cloud_type      = 1
  domain_name     = "avxr53testing.com"
  service_name    = "testvpn"
  elb_dns_names   = [
    aviatrix_gateway.r53_gw_1.elb_dns_name,
    aviatrix_gateway.r53_gw_3.elb_dns_name
  ]
}

output "test_geo_vpn_id" {
  value = aviatrix_geo_vpn.test_geo_vpn.id
}

################################################################
# GeoVPN user created under the DNS (supported as of R2.15) (14085)
resource "aviatrix_vpn_user" "geo_vpn_user" {
  user_name     = "geo-vpn-user"
  user_email    = null

  vpc_id      = null
  gw_name     = null
  dns_name    = join(".", [aviatrix_geo_vpn.test_geo_vpn.service_name, aviatrix_geo_vpn.test_geo_vpn.domain_name]) # use reference

  saml_endpoint = null

  manage_user_attachment = true
  profiles = null
}

output "geo_vpn_user_id" {
  value = aviatrix_vpn_user.geo_vpn_user.id
}
