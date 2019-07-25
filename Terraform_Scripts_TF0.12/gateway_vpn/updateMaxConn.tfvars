## Test case 7: update maximum vpn connections allowed to the gateway

aviatrix_vpn_cidr = "192.168.43.0/25"
aviatrix_vpn_max_conn = 25

aviatrix_vpn_split_tunnel                         = false # yes -> no
aviatrix_vpn_split_tunnel_search_domain_list      = "https://duckduckgo.com/" # google -> duckduckgo
aviatrix_vpn_split_tunnel_additional_cidrs_list   = "172.32.0.0/16" # removed 10.11.0.0/16
aviatrix_vpn_split_tunnel_name_servers_list       = "1.1.1.1" # removed Norton

aviatrix_single_az_ha = false # enabled -> disabled
