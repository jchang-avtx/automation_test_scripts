## Test case 1: enable single AZ HA

arm_gw_size       = "Standard_D5_v2"
arm_ha_gw_size    = "Standard_D5_v2"

toggle_snat       = true
single_az_ha      = true # false -> true

tgw_enable_hybrid             = false # not supported in Azure yet (18 apr)
tgw_enable_connected_transit  = true
