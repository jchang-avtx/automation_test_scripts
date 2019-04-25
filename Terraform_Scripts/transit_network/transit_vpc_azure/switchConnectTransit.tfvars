## Test case 1: disable connected_transit

arm_gw_size = "Standard_B1s"
arm_ha_gw_size = "Standard_B1s"

tgw_enable_hybrid = "false" # not supported in Azure yet (18 apr)
tgw_enable_connected_transit = "no" # yes -> no
