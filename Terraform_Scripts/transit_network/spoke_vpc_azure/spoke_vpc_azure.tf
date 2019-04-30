# Manage Aviatrix spoke_vpc (Azure)

resource "aviatrix_spoke_vpc" "test_spoke_vpc_arm" {
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "azureSpokeGW"
  vnet_and_resource_group_names = "SpokeVNet:SpokeRG"
  vpc_reg = "Central US"
  vpc_size = "${var.arm_gw_size}" # Standard_B1ms
  subnet = "10.3.0.0/24"
  ha_subnet = "${var.arm_ha_gw_subnet}" # default-spokeVNet-subnet
  ha_gw_size = "${var.arm_ha_gw_size}"
  enable_nat = "no"
  single_az_ha = "${var.toggle_single_az_ha}"
  transit_gw = "${var.attached_transit_gw}"
  # tag_list = ["k1:v1"] # not supported in Azure
}
