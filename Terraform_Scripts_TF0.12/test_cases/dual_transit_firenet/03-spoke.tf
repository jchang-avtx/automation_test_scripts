resource aviatrix_spoke_gateway dual_firenet_spoke_gw_1 {
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "dual-firenet-spoke-gw-1"
  vpc_id = aviatrix_vpc.dual_firenet_spoke_vpc_1.vpc_id
  vpc_reg = aviatrix_vpc.dual_firenet_spoke_vpc_1.region
  gw_size = "t3a.small"
  subnet = aviatrix_vpc.dual_firenet_spoke_vpc_1.public_subnets.0.cidr

  enable_active_mesh = true
  transit_gw = aviatrix_transit_gateway.transit_firenet_gw.gw_name
}

resource aviatrix_spoke_gateway dual_firenet_spoke_gw_2 {
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "dual-firenet-spoke-gw-2"
  vpc_id = aviatrix_vpc.dual_firenet_spoke_vpc_2.vpc_id
  vpc_reg = aviatrix_vpc.dual_firenet_spoke_vpc_2.region
  gw_size = "t3a.small"
  subnet = aviatrix_vpc.dual_firenet_spoke_vpc_2.public_subnets.0.cidr

  enable_active_mesh = true
  transit_gw = join(",", [aviatrix_transit_gateway.transit_firenet_gw.gw_name, aviatrix_transit_gateway.egress_firenet_gw.gw_name])
}
