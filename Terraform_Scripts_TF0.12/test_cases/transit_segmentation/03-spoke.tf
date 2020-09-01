resource aviatrix_spoke_gateway aws_segment_spoke_gw {
  for_each = {
    "eu-central-1" = "segment-spoke-eu-cent-1"
    "eu-west-1" = "segment-spoke-eu-west-1"
  }

  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = each.value
  vpc_id = aviatrix_vpc.aws_segment_spoke_vpc[each.key].vpc_id
  vpc_reg = aviatrix_vpc.aws_segment_spoke_vpc[each.key].region
  gw_size = "t3a.small"
  subnet = aviatrix_vpc.aws_segment_spoke_vpc[each.key].public_subnets.0.cidr

  enable_active_mesh = true
  transit_gw = aviatrix_transit_gateway.aws_segment_transit_gw.gw_name
}

resource aviatrix_spoke_gateway arm_segment_spoke_gw {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "arm-segment-spoke-gw"
  vpc_id = aviatrix_vpc.arm_segment_spoke_vnet[0].vpc_id
  vpc_reg = aviatrix_vpc.arm_segment_spoke_vnet[0].region
  gw_size = "Standard_B1ms"
  subnet = aviatrix_vpc.arm_segment_spoke_vnet[0].public_subnets.0.cidr

  enable_active_mesh = true
  transit_gw = aviatrix_transit_gateway.arm_segment_transit_gw[0].gw_name
}
