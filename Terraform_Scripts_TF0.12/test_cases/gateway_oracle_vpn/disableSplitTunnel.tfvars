## Test case 6: disable split tunnel

aviatrix_vpn_cidr = "192.168.43.0/25" # default is 192.168.43.0/24
aviatrix_vpn_max_conn = 100
aviatrix_vpn_nat = true

aviatrix_vpn_split_tunnel                         = false # yes -> no
aviatrix_vpn_split_tunnel_search_domain_list      = "" # google -> duckduckgo
aviatrix_vpn_split_tunnel_additional_cidrs_list   = "" # removed 10.11.0.0/16
aviatrix_vpn_split_tunnel_name_servers_list       = "" # Cloudflare DNS, Norton SafeConnect // removed Norton

aviatrix_single_az_ha = false # enabled -> disabled
