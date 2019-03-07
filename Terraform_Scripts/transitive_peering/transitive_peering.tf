## Create 2 NAT-enabled gateways for peering
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "NAT-gw1"
  vpc_id = "vpc-abc123"
  vpc_reg = "us-west-1"
  vpc_size = "t2.micro"
  vpc_net = "10.31.0.0/20"
  enable_nat = "yes"
}

resource "aviatrix_gateway" "test_gateway2" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "NAT-gw2"
  vpc_id = "vpc-def456"
  vpc_reg = "us-west-1"
  vpc_size = "t2.micro"
  vpc_net = "11.32.0.0/20"
  enable_nat = "yes"
}

# Create encrypted peering between two GWs
# A requirement for transitive peering feature
resource "aviatrix_tunnel" "encrypted-peering"{
  vpc_name1 = "${var.avx_tunnel_vpc1}"
  vpc_name2 = "${var.avx_tunnel_vpc2}"
  depends_on = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2"]
}
# setup a transitive peering
resource "aviatrix_trans_peer" "transitive-peering" {
  source         = "${var.transpeer_source}"
  nexthop        = "${var.transpeer_nexthop}"
  reachable_cidr = "${var.transpeer_reachable_cidr}"
  depends_on     = ["aviatrix_tunnel.encrypted-peering"]
}
