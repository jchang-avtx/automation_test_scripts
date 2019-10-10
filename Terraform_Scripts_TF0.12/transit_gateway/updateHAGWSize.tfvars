## Test case 5: Update transit_vpc's HA_GW size

gw_size               = "c5.xlarge"
aviatrix_ha_gw_size   = "c5.xlarge"

single_az_ha                  = true
tgw_enable_hybrid             = false
tgw_enable_connected_transit  = false

enable_vpc_dns_server = false
