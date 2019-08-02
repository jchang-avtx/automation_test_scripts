## Test Case 1: Disable single AZHA

arm_gw_size         = "Standard_D3_v2"

arm_ha_gw_subnet    = ""
arm_ha_gw_size      = ""

toggle_snat         = true
toggle_single_az_ha = false # enabled -> disabled

attached_transit_gw = ""
