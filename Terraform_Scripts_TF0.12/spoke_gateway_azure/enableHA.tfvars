## Test Case 2: Enable HA

arm_gw_size         = "Standard_D3_v2"

arm_ha_gw_subnet    = "10.3.2.128/26" # blank -> ha subnet
arm_ha_gw_size      = "Standard_D3_v2" # blank -> ha gw size

toggle_snat         = true
toggle_single_az_ha = false # enabled -> disabled

attached_transit_gw = ""
