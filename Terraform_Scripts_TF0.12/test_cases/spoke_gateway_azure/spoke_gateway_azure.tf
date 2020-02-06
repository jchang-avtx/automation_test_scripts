# Manage Aviatrix spoke_gateway (Azure)

resource "random_integer" "vnet1_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "arm_transit_gw_vnet" {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, random_integer.vnet1_cidr_int[2].result, "0/24"])
  cloud_type            = 8
  name                  = "arm-transit-gw-vnet"
  region                = "Central US"
}

resource "aviatrix_transit_gateway" "azure_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "azureTransitGW"
  vpc_id              = aviatrix_vpc.arm_transit_gw_vnet.vpc_id
  vpc_reg             = aviatrix_vpc.arm_transit_gw_vnet.region
  gw_size             = "Standard_B1s"
  subnet              = aviatrix_vpc.arm_transit_gw_vnet.subnets.0.cidr

  ha_subnet           = aviatrix_vpc.arm_transit_gw_vnet.subnets.2.cidr
  ha_gw_size          = "Standard_B1s"
  single_ip_snat      = false

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

  single_ip_snat       = false # insane mode does not support SNAT
  single_az_ha      = var.toggle_single_az_ha
  transit_gw        = var.attached_transit_gw
  enable_active_mesh= false
  depends_on        = ["aviatrix_transit_gateway.azure_transit_gw"]
}

output "test_spoke_gateway_arm_id" {
  value = aviatrix_spoke_gateway.test_spoke_gateway_arm.id
}
