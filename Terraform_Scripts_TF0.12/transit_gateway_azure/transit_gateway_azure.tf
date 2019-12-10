## Manage Aviatrix Transit Network Gateways

resource "aviatrix_transit_gateway" "azure_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "azureTransitGW"
  vpc_id              = "TransitVNet:TransitRG"
  vpc_reg             = "Central US"
  gw_size             = var.arm_gw_size
  # subnet              = "10.2.0.0/24" # non-insane
  subnet              = "10.2.2.0/26"

  # ha_subnet           = "10.2.0.0/24" # non-insane
  ha_subnet           = "10.2.2.64/26"
  ha_gw_size          = var.arm_ha_gw_size
  enable_snat         = false # insane mode does not support SNAT
  single_az_ha        = var.single_az_ha

  insane_mode               = true
  enable_hybrid_connection  = var.tgw_enable_hybrid
  connected_transit         = var.tgw_enable_connected_transit
  enable_active_mesh        = false
}

output "azure_transit_gw_id" {
  value = aviatrix_transit_gateway.azure_transit_gw.id
}
