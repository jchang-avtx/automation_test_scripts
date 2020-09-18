resource aviatrix_spoke_gateway dual_firenet_azure_spoke_gw_1 {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "dual-firenet-azure-spoke-gw-1"
  vpc_id = aviatrix_vpc.dual_firenet_spoke_vnet_1[0].vpc_id
  vpc_reg = aviatrix_vpc.dual_firenet_spoke_vnet_1[0].region
  gw_size = "Standard_B2ms"
  subnet = aviatrix_vpc.dual_firenet_spoke_vnet_1[0].public_subnets.0.cidr

  enable_active_mesh = true
  transit_gw = aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name
}

resource aviatrix_spoke_gateway dual_firenet_azure_spoke_gw_2 {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "dual-firenet-azure-spoke-gw-2"
  vpc_id = aviatrix_vpc.dual_firenet_spoke_vnet_2[0].vpc_id
  vpc_reg = aviatrix_vpc.dual_firenet_spoke_vnet_2[0].region
  gw_size = "Standard_B2ms"
  subnet = aviatrix_vpc.dual_firenet_spoke_vnet_2[0].public_subnets.0.cidr

  enable_active_mesh = true
  transit_gw = join(",", [aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name, aviatrix_transit_gateway.azure_egress_firenet_gw[0].gw_name])
}
