## Test Case 5: attach transit gw

arm_gw_size = "Standard_B1ms" # Standard_B1s -> B1ms

arm_ha_gw_subnet = "10.3.0.0/24" # blank -> ha subnet
arm_ha_gw_size = "Standard_B1ms" # B1s -> B1ms

toggle_single_az_ha = "disabled" # enabled -> disabled

attached_transit_gw = "azureTransitGW" # blank -> transitGW
