## Test case 2: update GW size

arm_gw_size       = "Standard_B1ms" # Standard_B1s -> B1ms
arm_ha_gw_size    = "Standard_B1s"

toggle_snat       = true

tgw_enable_hybrid             = false # not supported in Azure yet (18 apr)
tgw_enable_connected_transit  = false # yes -> no
