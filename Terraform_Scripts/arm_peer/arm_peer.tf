# Create Aviatrix ARM Peering
resource "aviatrix_arm_peer" "test_armpeer" {
  account_name1             = "test1-account"
  account_name2             = "test2-account"
  vnet_name_resource_group1 = "VNet1:ResourceGroup1"
  vnet_name_resource_group2 = "VNet2:ResourceGroup2"
  vnet_reg1                 = "Central US"
  vnet_reg2                 = "East US"
}
