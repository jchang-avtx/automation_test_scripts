## Build encrypted peering between Aviatrix gateways in HA mode
## Creates 2 GWs and a peering tunnel

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

resource "aviatrix_vpc" "aws_tunnel_vpc_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-tunnel-vpc-1"
  region                = "us-east-1"
}

resource "aviatrix_vpc" "aws_tunnel_vpc_2" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-tunnel-vpc-2"
  region                = "us-west-1"
}

resource "aviatrix_gateway" "peeringGW1" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "peeringGW1"
  vpc_id              = aviatrix_vpc.aws_tunnel_vpc_1.vpc_id
  vpc_reg             = aviatrix_vpc.aws_tunnel_vpc_1.region
  gw_size             = "t2.micro"
  subnet              = aviatrix_vpc.aws_tunnel_vpc_1.subnets.6.cidr

  peering_ha_subnet   = aviatrix_vpc.aws_tunnel_vpc_1.subnets.7.cidr
  peering_ha_gw_size  = "t2.micro"
}

resource "aviatrix_gateway" "peeringGW2" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "peeringGW2"
  vpc_id              = aviatrix_vpc.aws_tunnel_vpc_2.vpc_id
  vpc_reg             = aviatrix_vpc.aws_tunnel_vpc_2.region
  gw_size             = "t2.micro"
  subnet              = aviatrix_vpc.aws_tunnel_vpc_2.subnets.2.cidr

  peering_ha_subnet   = aviatrix_vpc.aws_tunnel_vpc_2.subnets.3.cidr
  peering_ha_gw_size  = "t2.micro"
}

# Create encrypted peering between two aviatrix gateway
resource "aviatrix_tunnel" "peeringTunnel" {
  gw_name1      = aviatrix_gateway.peeringGW1.gw_name
  gw_name2      = aviatrix_gateway.peeringGW2.gw_name
  enable_ha     = true
}

output "peeringTunnel_id" {
  value = aviatrix_tunnel.peeringTunnel.id
}
