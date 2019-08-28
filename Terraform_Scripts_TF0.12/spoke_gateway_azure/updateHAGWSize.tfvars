## Test Case 4: Update GW Size

arm_gw_size         = "Standard_D4_v2" # D3 -> D4

arm_ha_gw_subnet    = "10.3.2.128/26" # blank -> ha subnet
# arm_ha_gw_subnet    = "10.3.0.0/24" # non-insane
arm_ha_gw_size      = "Standard_D4_v2" # D3 -> D4

toggle_snat         = true
toggle_single_az_ha = false # enabled -> disabled

attached_transit_gw = ""
