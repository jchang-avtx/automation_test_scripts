## Test case 6: disable split tunnel

aviatrix_vpn_cidr = "192.168.43.0/25" # default is 192.168.43.0/24
aviatrix_vpn_max_conn = 100
aviatrix_vpn_nat = true

aviatrix_vpn_split_tunnel = false # yes -> no

aviatrix_single_az_ha = false # enabled -> disabled
