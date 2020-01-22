## Create Aviatrix transit gateway peering
## Must first create 2 Transit GWs before creating the peering of the two

resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 223
}

resource "random_integer" "vpc2_cidr_int" {
  count = 2
  min = 1
  max = 223
}

resource "aviatrix_vpc" "aws_transit_gw_vpc_1" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "aws-transit-gw-vpc-1"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_vpc" "aws_transit_gw_vpc_2" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-west-1"
  name                  = "aws-transit-gw-vpc-2"
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_transit_gateway" "test_transit_gw1" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "test-transit-gw1"
  enable_snat       = true
  vpc_id            = aviatrix_vpc.aws_transit_gw_vpc_1.vpc_id
  vpc_reg           = aviatrix_vpc.aws_transit_gw_vpc_1.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.aws_transit_gw_vpc_1.subnets.4.cidr

  enable_hybrid_connection = false
  connected_transit = true
}

resource "aviatrix_transit_gateway" "test_transit_gw2" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "test-transit-gw2"
  enable_snat       = true
  vpc_id            = aviatrix_vpc.aws_transit_gw_vpc_2.vpc_id
  vpc_reg           = aviatrix_vpc.aws_transit_gw_vpc_2.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.aws_transit_gw_vpc_2.subnets.4.cidr

  enable_hybrid_connection  = false
  connected_transit         = true
}

resource "aviatrix_transit_gateway_peering" "test_transit_gw_peering" {
  transit_gateway_name1 = aviatrix_transit_gateway.test_transit_gw1.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.test_transit_gw2.gw_name
}

output "test_transit_gw_peering_id" {
  value = aviatrix_transit_gateway_peering.test_transit_gw_peering.id
}
