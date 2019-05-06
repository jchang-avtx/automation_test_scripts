## Test Case 2: Enable HA

arm_gw_size = "Standard_B1s"

arm_ha_gw_subnet = "10.3.0.0/24" # blank -> ha subnet
arm_ha_gw_size = "Standard_B1s" # blank -> ha gw size

toggle_snat = "yes"
toggle_single_az_ha = "disabled" # enabled -> disabled

attached_transit_gw = ""
