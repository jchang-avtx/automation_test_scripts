
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type      = 1
  account_name    = "AnthonyPrimaryAccess"
  gw_name         = "NAT-gw1"
  vpc_id          = "vpc-ba3c12dd"
  vpc_reg         = "us-west-1"
  vpc_size        = "t2.micro"
  vpc_net         = "172.31.0.0/20"
  enable_nat      = "yes"
}

resource "aviatrix_gateway" "test_gateway2" {
  cloud_type      = 1
  account_name    = "AnthonyPrimaryAccess"
  gw_name         = "NAT-gw2"
  vpc_id          = "vpc-0cbdc7571b2fd28bf"
  vpc_reg         = "us-west-1"
  vpc_size        = "t2.micro"
  vpc_net         = "100.200.0.0/16"
  enable_nat      = "yes"
}

# Create encrypted peering between two GWs
# A requirement for transitive peering feature
resource "aviatrix_tunnel" "encrypted-peering"{
  vpc_name1     = aviatrix_gateway.test_gateway1.gw_name
  vpc_name2     = aviatrix_gateway.test_gateway2.gw_name
  depends_on    = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2"]
}

resource "aviatrix_trans_peer" "transitive-peering" {
  source          = aviatrix_gateway.test_gateway1.gw_name
  nexthop         = aviatrix_gateway.test_gateway2.gw_name
  reachable_cidr  = "55.55.55.0/24"
  depends_on      = ["aviatrix_tunnel.encrypted-peering"]
}
