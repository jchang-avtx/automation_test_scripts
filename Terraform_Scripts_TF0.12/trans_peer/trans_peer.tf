
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "NAT-gw1"
  vpc_id          = "vpc-ba3c12dd"
  vpc_reg         = "us-west-1"
  gw_size         = "t2.micro"
  subnet          = "172.31.0.0/20"
  enable_snat     = true
}

resource "aviatrix_gateway" "test_gateway2" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "NAT-gw2"
  vpc_id          = "vpc-0cbdc7571b2fd28bf"
  vpc_reg         = "us-west-1"
  gw_size         = "t2.micro"
  subnet          = "100.200.0.0/16"
  enable_snat     = true
}

# Create encrypted peering between two GWs
# A requirement for transitive peering feature
resource "aviatrix_tunnel" "encrypted-peering"{
  gw_name1      = aviatrix_gateway.test_gateway1.gw_name
  gw_name2      = aviatrix_gateway.test_gateway2.gw_name
  depends_on    = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2"]
}

resource "aviatrix_trans_peer" "transitive-peering" {
  source          = aviatrix_gateway.test_gateway1.gw_name
  nexthop         = aviatrix_gateway.test_gateway2.gw_name
  reachable_cidr  = "55.55.55.0/24"
  depends_on      = ["aviatrix_tunnel.encrypted-peering"]
}
