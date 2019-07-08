## Test case 1: update VPN CIDR

aviatrix_vpn_cidr = "192.168.43.0/25"
aviatrix_vpn_max_conn = 100

aviatrix_vpn_split_tunnel                         = "yes"
aviatrix_vpn_split_tunnel_search_domain_list      = "https://www.google.com"
aviatrix_vpn_split_tunnel_additional_cidrs_list   = "172.32.0.0/16,10.11.0.0/16"
aviatrix_vpn_split_tunnel_name_servers_list       = "1.1.1.1,199.85.126.10"

aviatrix_single_az_ha = "enabled"
