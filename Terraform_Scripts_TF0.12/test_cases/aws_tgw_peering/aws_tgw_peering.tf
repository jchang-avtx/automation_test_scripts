resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 223
}

resource "aviatrix_vpc" "tgw_peer_transit_vpc_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "tgw-peer-transit-vpc-1"
  region                = "eu-central-1"
}

resource "aviatrix_transit_gateway" "tgw_peer_transit_gw_1" {
  cloud_type                  = 1
  account_name                = "AWSAccess"
  gw_name                     = "tgw-peer-transit-gw-1"
  vpc_id                      = aviatrix_vpc.tgw_peer_transit_vpc_1.vpc_id
  vpc_reg                     = aviatrix_vpc.tgw_peer_transit_vpc_1.region
  gw_size                     = "t2.micro"
  subnet                      = aviatrix_vpc.tgw_peer_transit_vpc_1.subnets.4.cidr

  enable_hybrid_connection    = true
  connected_transit           = false
  enable_active_mesh          = false
}

resource "aws_vpn_gateway" "eu_tgw_peer_vgw" {
  tags = {
    Name = "eu-tgw-peer-vgw"
  }
  amazon_side_asn = 64513
}

resource "aviatrix_vgw_conn" "tgw_vgw_conn_1" {
  conn_name             = "tgw-vgw-conn-1"
  gw_name               = aviatrix_transit_gateway.tgw_peer_transit_gw_1.gw_name
  vpc_id                = aviatrix_transit_gateway.tgw_peer_transit_gw_1.vpc_id
  bgp_vgw_id            = aws_vpn_gateway.eu_tgw_peer_vgw.id
  bgp_vgw_account       = aviatrix_transit_gateway.tgw_peer_transit_gw_1.account_name
  bgp_vgw_region        = aviatrix_transit_gateway.tgw_peer_transit_gw_1.vpc_reg
  bgp_local_as_num      = 65001
}

resource "aviatrix_aws_tgw" "peer_tgw_1" {
  tgw_name        = "aws_tgw_peer_1"
  account_name    = "AWSAccess"
  region          = "eu-central-1"
  aws_side_as_number = 65413
  # attached_aviatrix_transit_gateway = []
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
  }
  manage_vpc_attachment                 = false
  manage_transit_gateway_attachment     = false
}

################################################################
resource "random_integer" "vpc2_cidr_int" {
  count = 2
  min = 1
  max = 223
}

resource "aviatrix_vpc" "tgw_peer_transit_vpc_2" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "tgw-peer-transit-vpc-2"
  region                = "us-east-1"
}

resource "aviatrix_transit_gateway" "tgw_peer_transit_gw_2" {
  cloud_type                  = 1
  account_name                = "AWSAccess"
  gw_name                     = "tgw-peer-transit-gw-2"
  vpc_id                      = aviatrix_vpc.tgw_peer_transit_vpc_2.vpc_id
  vpc_reg                     = aviatrix_vpc.tgw_peer_transit_vpc_2.region
  gw_size                     = "t2.micro"
  subnet                      = aviatrix_vpc.tgw_peer_transit_vpc_2.subnets.4.cidr

  enable_hybrid_connection    = true
  connected_transit           = false
  enable_active_mesh          = false
}

resource "aws_vpn_gateway" "us_tgw_peer_vgw" {
  provider = aws.us-east-1
  tags = {
    Name = "us-tgw-peer-vgw"
  }
  amazon_side_asn = 64514
}

resource "aviatrix_vgw_conn" "tgw_vgw_conn_2" {
  conn_name             = "tgw-vgw-conn-2"
  gw_name               = aviatrix_transit_gateway.tgw_peer_transit_gw_2.gw_name
  vpc_id                = aviatrix_transit_gateway.tgw_peer_transit_gw_2.vpc_id
  bgp_vgw_id            = aws_vpn_gateway.us_tgw_peer_vgw.id
  bgp_vgw_account       = aviatrix_transit_gateway.tgw_peer_transit_gw_2.account_name
  bgp_vgw_region        = aviatrix_transit_gateway.tgw_peer_transit_gw_2.vpc_reg
  bgp_local_as_num      = 65002
}

resource "aviatrix_aws_tgw" "peer_tgw_2" {
  tgw_name        = "aws_tgw_peer_2"
  account_name    = "AWSAccess"
  region          = "us-east-1"
  aws_side_as_number = 65414
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
  }
  manage_vpc_attachment                 = false
  manage_transit_gateway_attachment     = false
}

################################################################
resource "aviatrix_aws_tgw_peering_domain_conn" "tgw_peer_domain_conn_1" {
  tgw_name1       = aviatrix_aws_tgw.peer_tgw_1.tgw_name
  domain_name1    = "Shared_Service_Domain"
  tgw_name2       = aviatrix_aws_tgw.peer_tgw_2.tgw_name
  domain_name2    = "Aviatrix_Edge_Domain"

  depends_on = [aviatrix_aws_tgw_peering.tgw_peering]
}

resource "aviatrix_aws_tgw_peering_domain_conn" "tgw_peer_domain_conn_2" {
  tgw_name1       = aviatrix_aws_tgw.peer_tgw_1.tgw_name
  domain_name1    = "Default_Domain"
  tgw_name2       = aviatrix_aws_tgw.peer_tgw_1.tgw_name
  domain_name2    = "Aviatrix_Edge_Domain"
  
  depends_on = [aviatrix_aws_tgw_peering.tgw_peering]
}

output "tgw_peer_domain_conn_1" {
  value = aviatrix_aws_tgw_peering_domain_conn.tgw_peer_domain_conn_1.id
}

output "tgw_peer_domain_conn_2" {
  value = aviatrix_aws_tgw_peering_domain_conn.tgw_peer_domain_conn_2.id
}

################################################################

resource "aviatrix_aws_tgw_peering" "tgw_peering"{
  tgw_name1 = aviatrix_aws_tgw.peer_tgw_2.tgw_name
  tgw_name2 = aviatrix_aws_tgw.peer_tgw_1.tgw_name
}

output "tgw_peering_id" {
  value = aviatrix_aws_tgw_peering.tgw_peering.id
}
