## Create Aviatrix AWS Peering

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "aviatrix_vpc" "aws_vpc_peer_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "awsVPCpeer1"
  region                = "us-west-1"
}

resource "aviatrix_vpc" "aws_vpc_peer_2" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "awsVPCpeer2"
  region                = "us-west-1"
}

data "aws_route_table" "aws_vpc_peer_1_rtb" {
  vpc_id      = aviatrix_vpc.aws_vpc_peer_1.vpc_id
  subnet_id   = aviatrix_vpc.aws_vpc_peer_1.subnets.3.subnet_id
}

data "aws_route_table" "aws_vpc_peer_2_rtb" {
  vpc_id      = aviatrix_vpc.aws_vpc_peer_2.vpc_id
  subnet_id   = aviatrix_vpc.aws_vpc_peer_2.subnets.3.subnet_id
}

resource "aviatrix_aws_peer" "test_awspeer" {
  account_name1 = "AWSAccess"
  account_name2 = "AWSAccess"

  vpc_id1       = aviatrix_vpc.aws_vpc_peer_1.vpc_id
  vpc_id2       = aviatrix_vpc.aws_vpc_peer_2.vpc_id
  vpc_reg1      = aviatrix_vpc.aws_vpc_peer_1.region
  vpc_reg2      = aviatrix_vpc.aws_vpc_peer_2.region
  rtb_list1     = [data.aws_route_table.aws_vpc_peer_1_rtb.id]
  rtb_list2     = [data.aws_route_table.aws_vpc_peer_2_rtb.id]
}

output "test_awspeer_id" {
  value = aviatrix_aws_peer.test_awspeer.id
}
