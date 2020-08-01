## Create Aviatrix transit gateway peering
## Must first create 2 Transit GWs before creating the peering of the two

resource random_integer vpc1_cidr_int {
  count = 2
  min = 1
  max = 126
}

resource random_integer vpc2_cidr_int {
  count = 2
  min = 1
  max = 126
}

resource aviatrix_vpc aws_transit_gw_vpc_1 {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "aws-transit-gw-vpc-1"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource aviatrix_vpc aws_transit_gw_vpc_2 {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-west-1"
  name                  = "aws-transit-gw-vpc-2"
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource aviatrix_transit_gateway test_transit_gw1 {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "test-transit-gw1"
  single_ip_snat    = true
  vpc_id            = aviatrix_vpc.aws_transit_gw_vpc_1.vpc_id
  vpc_reg           = aviatrix_vpc.aws_transit_gw_vpc_1.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.aws_transit_gw_vpc_1.subnets.4.cidr

  enable_hybrid_connection  = true
  connected_transit         = true
  enable_active_mesh        = false # (16300) TGW peering needs to handle non-active mesh test case
}

resource aviatrix_transit_gateway test_transit_gw2 {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "test-transit-gw2"
  single_ip_snat    = true
  vpc_id            = aviatrix_vpc.aws_transit_gw_vpc_2.vpc_id
  vpc_reg           = aviatrix_vpc.aws_transit_gw_vpc_2.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.aws_transit_gw_vpc_2.subnets.4.cidr

  enable_hybrid_connection  = true
  connected_transit         = true
  enable_active_mesh        = false # (16300) TGW peering needs to handle non-active mesh test case
}

resource aviatrix_transit_gateway_peering test_transit_gw_peering {
  transit_gateway_name1 = aviatrix_transit_gateway.test_transit_gw1.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.test_transit_gw2.gw_name

  gateway1_excluded_network_cidrs = ["11.11.11.11/32"]
  gateway2_excluded_network_cidrs = ["11.11.11.11/32"]

  gateway1_excluded_tgw_connections = [aviatrix_aws_tgw_vpn_conn.exclude_tgw_vpn_conn.connection_name]
  gateway2_excluded_tgw_connections = null
}

# TGW and TGW VPN conn added to support R2.16 transit gw peering features
resource aviatrix_aws_tgw exclude_tgw {
  tgw_name                          = "exclude-tgw"
  account_name                      = "AWSAccess"
  region                            = aviatrix_transit_gateway.test_transit_gw1.vpc_reg
  aws_side_as_number                = 4294967294
  attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.test_transit_gw1.gw_name]

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
  }

  manage_vpc_attachment = true
  manage_transit_gateway_attachment = true
}

resource aviatrix_aws_tgw_vpn_conn exclude_tgw_vpn_conn {
  tgw_name             = aviatrix_aws_tgw.exclude_tgw.tgw_name
  route_domain_name    = "Default_Domain"
  connection_name      = "exclude-tgw-vpn-conn"
  connection_type      = "dynamic"
  public_ip            = "1.2.3.4"
  remote_as_number     = 1234
}

output test_transit_gw_peering_id {
  value = aviatrix_transit_gateway_peering.test_transit_gw_peering.id
}
