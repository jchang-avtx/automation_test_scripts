## Test case 11: Update BGP related variables

gw_size               = "c5.xlarge"
aviatrix_ha_gw_size   = "c5.xlarge"

single_az_ha                  = true
tgw_enable_hybrid             = false
tgw_enable_connected_transit  = false

enable_vpc_dns_server = true
enable_learned_cidrs_approval = false

custom_spoke_vpc_routes = "13.23.4.4/32,14.23.4.4/32,12.23.4.4/32"
filter_spoke_vpc_routes = "13.24.5.5/32,14.24.5.5/32"
exclude_advertise_spoke_routes = "14.25.6.6/32,15.25.6.6/32,13.25.6.6/32"

bgp_ecmp_status = false
bgp_polling_time = 40
