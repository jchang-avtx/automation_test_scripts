## Test case 2: Update transit_vpc's connected_transit status

gw_size               = "c5.large"
aviatrix_ha_gw_size   = "c5.large"

single_az_ha                  = true
tgw_enable_hybrid             = true
tgw_enable_connected_transit  = false

enable_vpc_dns_server = false
