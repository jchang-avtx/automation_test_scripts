resource "aviatrix_vpc" "r53_vpc" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-2"
  name                  = "r53VPC"
  cidr                  = "153.147.0.0/16"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_gateway" "r53_gw" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "r53GW"
  vpc_id            = aviatrix_vpc.r53_vpc.vpc_id
  vpc_reg           = aviatrix_vpc.r53_vpc.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.r53_vpc.subnets.3.cidr

  single_az_ha      = false
  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = "192.168.43.0/24"
  enable_elb        = true
  enable_vpn_nat    = true
  elb_name          = "elb-r53"
  max_vpn_conn      = 100
}

resource "aviatrix_geo_vpn" "test_geo_vpn" {
  account_name    = "AWSAccess"
  cloud_type      = 1
  domain_name     = "avxr53testing.com"
  service_name    = "testvpn"
  elb_dns_names   = [
    aviatrix_gateway.r53_gw.elb_dns_name
  ]
}

output "test_geo_vpn_id" {
  value = aviatrix_geo_vpn.test_geo_vpn.id
}
