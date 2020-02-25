## Manage Aviatrix Transit Network Gateways

resource "random_integer" "vnet1_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "aviatrix_vpc" "arm_transit_gw_vnet" {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, "0.0/16"])
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
  gw_size             = var.arm_gw_size
  # subnet              = "10.2.0.0/24" # non-insane
  subnet              = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, "64.0/26"]) # "10.2.2.0/26"

  # ha_subnet           = "10.2.0.0/24" # non-insane
  ha_subnet           = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, "64.64/26"]) # "10.2.2.64/26"
  ha_gw_size          = var.arm_ha_gw_size
  single_ip_snat      = false # insane mode does not support SNAT
  single_az_ha        = var.single_az_ha

  insane_mode               = true
  enable_hybrid_connection  = var.tgw_enable_hybrid
  connected_transit         = var.tgw_enable_connected_transit
  enable_active_mesh        = false
}

output "azure_transit_gw_id" {
  value = aviatrix_transit_gateway.azure_transit_gw.id
}
