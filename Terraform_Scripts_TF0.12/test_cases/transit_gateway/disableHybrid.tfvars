## Test case 3: Update transit_vpc's enable_hybrid_connection (disable)

gw_size               = "c5.large"
aviatrix_ha_gw_size   = "c5.large"

single_az_ha                  = true
tgw_enable_hybrid             = false
tgw_enable_connected_transit  = false

enable_vpc_dns_server = false
