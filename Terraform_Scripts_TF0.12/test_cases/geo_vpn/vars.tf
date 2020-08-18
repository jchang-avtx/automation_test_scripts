variable vpn_nat_status {
  description = "Enable for VPN connection to use NAT while VPN traffic leaves the VPN gateway"
  default = true
}

variable max_vpn_conn {
  description = "Max number of active VPN users allowed to be connected to gateway"
  default = 100
}

variable vpn_split_tunnel {
  description = "Enabled by default, only traffic destined to VPC CIDR where VPN gateway is deployed, is going to the VPN tunnel when user is connected to VPN gateway"
  default = true
}

variable vpn_split_tunnel_search_domain_list {
  description = "Specify list of domain names that will use nameserver when a specific name is not in destination"
  default = "https://www.google.com"
}

variable vpn_split_tunnel_additional_cidrs_list {
  description = "Specify list of dest. CIDR ranges that will also go thru VPN tunnel"
  default = "10.11.0.0/16"
}

variable vpn_split_tunnel_name_servers_list {
  description = "Specify DNS servers to resolve domain names"
  default = "1.1.1.1,199.85.126.10" # Cloudflare DNS, Norton SafeConnect
}
