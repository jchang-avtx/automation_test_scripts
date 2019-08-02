## Test case 4: disable SNAT

arm_gw_size       = "Standard_D4_v2" # Standard_B1s -> B1ms
arm_ha_gw_size    = "Standard_D4_v2" # Standard_B1s -> B1ms

toggle_snat       = false # yes -> no

tgw_enable_hybrid             = false # not supported in Azure yet (18 apr)
tgw_enable_connected_transit  = false # yes -> no
