# Manage Aviatrix spoke_gateway (Azure)

resource "aviatrix_transit_gateway" "azure_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "azureTransitGW"
  vpc_id              = "TransitVNet:TransitRG"
  vpc_reg             = "Central US"
  gw_size             = "Standard_B1s"
  subnet              = "10.2.0.0/24"

  ha_subnet           = "10.2.0.0/24"
  ha_gw_size          = "Standard_B1s"
  enable_snat         = false

  enable_hybrid_connection  = false
  connected_transit         = true
  enable_active_mesh        = false
}

resource "aviatrix_spoke_gateway" "test_spoke_gateway_arm" {
  cloud_type        = 8
  account_name      = "AzureAccess"
  gw_name           = "azureSpokeGW"
  vpc_id            = "SpokeVNet:SpokeRG"
  vpc_reg           = "Central US"
  gw_size           = var.arm_gw_size

  insane_mode       = true
  subnet            = "10.3.2.64/26"
  # subnet            = "10.3.0.0/24" # non-insane

  ha_subnet         = var.arm_ha_gw_subnet
  ha_gw_size        = var.arm_ha_gw_size

  enable_snat       = false # insane mode does not support SNAT
  single_az_ha      = var.toggle_single_az_ha
  transit_gw        = var.attached_transit_gw
  enable_active_mesh= false
  depends_on        = ["aviatrix_transit_gateway.azure_transit_gw"]
}

output "test_spoke_gateway_arm_id" {
  value = aviatrix_spoke_gateway.test_spoke_gateway_arm.id
}
