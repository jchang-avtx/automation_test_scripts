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

resource aviatrix_spoke_gateway gcp_segment_spoke_gw {
  count = var.enable_gcp ? 1 : 0
  cloud_type = 4
  account_name = "GCPAccess"
  gw_name = "gcp-segment-spoke-gw"
  vpc_id = "gcpspokevpc" # aviatrix_vpc.gcp_segment_vpc[0].vpc_id
  vpc_reg = "europe-west1-d" # "${aviatrix_vpc.gcp_segment_vpc[0].subnets.1.region}-b"
  gw_size = "n1-standard-1"
  subnet = "172.24.0.0/16" # aviatrix_vpc.gcp_segment_vpc[0].subnets.1.cidr

  enable_active_mesh = true
  transit_gw = aviatrix_transit_gateway.gcp_segment_transit_gw[0].gw_name
}
