## Test case 4: disable SNAT

arm_gw_size = "Standard_B1ms" # Standard_B1s -> B1ms
arm_ha_gw_size = "Standard_B1ms" # Standard_B1s -> B1ms

toggle_snat = "no" # yes -> no

tgw_enable_hybrid = "false" # not supported in Azure yet (18 apr)
tgw_enable_connected_transit = "no" # yes -> no
