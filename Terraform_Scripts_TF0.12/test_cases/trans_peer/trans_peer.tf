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

resource "aviatrix_vpc" "aws_trans_peer_vpc_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-trans-peer-vpc-1"
  region                = "us-east-1"
}

resource "aviatrix_vpc" "aws_trans_peer_vpc_2" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-trans-peer-vpc-2"
  region                = "us-west-1"
}


resource "aviatrix_gateway" "test_gateway1" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "NAT-gw1"
  vpc_id          = aviatrix_vpc.aws_trans_peer_vpc_1.vpc_id
  vpc_reg         = aviatrix_vpc.aws_trans_peer_vpc_1.region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.aws_trans_peer_vpc_1.subnets.6.cidr
  enable_snat     = true
}

resource "aviatrix_gateway" "test_gateway2" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "NAT-gw2"
  vpc_id          = aviatrix_vpc.aws_trans_peer_vpc_2.vpc_id
  vpc_reg         = aviatrix_vpc.aws_trans_peer_vpc_2.region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.aws_trans_peer_vpc_2.subnets.2.cidr
  enable_snat     = true
}

# Create encrypted peering between two GWs
# A requirement for transitive peering feature
resource "aviatrix_tunnel" "encrypted-peering"{
  gw_name1      = aviatrix_gateway.test_gateway1.gw_name
  gw_name2      = aviatrix_gateway.test_gateway2.gw_name
}

resource "aviatrix_trans_peer" "transitive-peering" {
  source          = aviatrix_gateway.test_gateway1.gw_name
  nexthop         = aviatrix_gateway.test_gateway2.gw_name
  reachable_cidr  = "55.55.55.0/24"
  depends_on      = ["aviatrix_tunnel.encrypted-peering"]
}

output "transitive-peering_id" {
  value = aviatrix_trans_peer.transitive-peering.id
}
