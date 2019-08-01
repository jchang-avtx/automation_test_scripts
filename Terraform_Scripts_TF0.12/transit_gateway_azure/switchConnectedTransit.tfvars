## Test case 1: disable connected_transit

arm_gw_size       = "Standard_D5_v2"
arm_ha_gw_size    = "Standard_D5_v2"

toggle_snat       = true

tgw_enable_hybrid             = false # not supported in Azure yet (18 apr)
tgw_enable_connected_transit  = false # yes -> no
