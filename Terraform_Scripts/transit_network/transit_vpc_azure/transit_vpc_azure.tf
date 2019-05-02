## Manage Aviatrix Transit Network Gateways

resource "aviatrix_transit_vpc" "azure_transit_gw" {
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "azureTransitGW"
  vnet_name_resource_group = "TransitVNet:TransitRG" # VNet2:NetworkWatcherRG (should block update)
  vpc_reg = "Central US"
  vpc_size = "${var.arm_gw_size}" # Standard_B1ms
  subnet = "10.2.0.0/24"
  ha_subnet = "10.2.0.0/24"
  ha_gw_size = "${var.arm_ha_gw_size}"
  enable_nat = "no"
  enable_hybrid_connection = "${var.tgw_enable_hybrid}" # 'true' not supported in Azure
  # tag_list = ["k1:v1"] # not supported in Azure
  connected_transit = "${var.tgw_enable_connected_transit}" # connected_transit update works
}
