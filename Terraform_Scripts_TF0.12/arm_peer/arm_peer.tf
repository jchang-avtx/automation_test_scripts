# Create Aviatrix ARM Peering
resource "aviatrix_arm_peer" "test_armpeer" {
  account_name1             = var.acc_1
  account_name2             = var.acc_2
  vnet_name_resource_group1 = var.vnet_rg1
  vnet_name_resource_group2 = var.vnet_rg2
  vnet_reg1                 = var.vnet_reg1
  vnet_reg2                 = var.vnet_reg2
}

output "test_armpeer_id" {
  value = aviatrix_arm_peer.test_armpeer.id
}
