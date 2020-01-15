## Test case: test regular gateway

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "aws_gw_vpc_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-gw-vpc-1"
  region                = "us-east-1"
}

resource "aviatrix_gateway" "testGW1" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "testGW1"
  vpc_id              = aviatrix_vpc.aws_gw_vpc_1.vpc_id
  vpc_reg             = aviatrix_vpc.aws_gw_vpc_1.region
  gw_size             = var.aws_instance_size
  subnet              = aviatrix_vpc.aws_gw_vpc_1.subnets.6.cidr

  tag_list            = var.aws_gateway_tag_list
  enable_snat         = var.enable_snat

  allocate_new_eip    = false
  eip                 = "52.86.21.117"

  peering_ha_subnet   = aviatrix_vpc.aws_gw_vpc_1.subnets.7.cidr
  peering_ha_gw_size  = var.aws_ha_gw_size
  peering_ha_eip      = "52.204.201.204"

  enable_vpc_dns_server = var.enable_vpc_dns_server
}

output "testGW1_id" {
  value = aviatrix_gateway.testGW1.id
}
