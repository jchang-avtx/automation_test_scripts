## initial creation

aviatrix_vpn_cidr = "192.168.44.0/24"
aviatrix_vpn_max_conn = 100
aviatrix_vpn_nat = true

aviatrix_vpn_split_tunnel                         = true
aviatrix_vpn_split_tunnel_search_domain_list      = "https://www.google.com"
aviatrix_vpn_split_tunnel_additional_cidrs_list   = "10.11.0.0/16"
aviatrix_vpn_split_tunnel_name_servers_list       = "1.1.1.1,199.85.126.10" # Cloudflare DNS, Norton SafeConnect

aviatrix_single_az_ha = true
