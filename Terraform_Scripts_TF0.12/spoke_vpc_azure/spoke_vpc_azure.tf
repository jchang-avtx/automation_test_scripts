# Manage Aviatrix spoke_vpc (Azure)

resource "aviatrix_transit_vpc" "azure_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "azureTransitGW"
  vpc_id              = "TransitVNet:TransitRG"
  vpc_reg             = "Central US"
  vpc_size            = "Standard_B1s"
  subnet              = "10.2.0.0/24"

  ha_subnet           = "10.2.0.0/24"
  ha_gw_size          = "Standard_B1s"
  enable_nat          = "yes"

  enable_hybrid_connection  = false
  connected_transit         = "yes"
}

resource "aviatrix_spoke_vpc" "test_spoke_vpc_arm" {
  cloud_type        = 8
  account_name      = "AzureAccess"
  gw_name           = "azureSpokeGW"
  vpc_id            = "SpokeVNet:SpokeRG"
  vpc_reg           = "Central US"
  vpc_size          = var.arm_gw_size
  subnet            = "10.3.0.0/24"

  ha_subnet         = var.arm_ha_gw_subnet
  ha_gw_size        = var.arm_ha_gw_size

  enable_nat        = var.toggle_snat
  single_az_ha      = var.toggle_single_az_ha
  transit_gw        = var.attached_transit_gw
  depends_on        = ["aviatrix_transit_vpc.azure_transit_gw"]
}
