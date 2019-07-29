## Manage Aviatrix Transit Network Gateways

resource "aviatrix_transit_gateway" "azure_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "azureTransitGW"
  vpc_id              = "TransitVNet:TransitRG"
  vpc_reg             = "Central US"
  gw_size             = var.arm_gw_size
  subnet              = "10.2.0.0/24"

  ha_subnet           = "10.2.0.0/24"
  ha_gw_size          = var.arm_ha_gw_size
  enable_snat         = var.toggle_snat

  enable_hybrid_connection  = var.tgw_enable_hybrid
  connected_transit         = var.tgw_enable_connected_transit
}
