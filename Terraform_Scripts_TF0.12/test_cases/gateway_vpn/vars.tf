variable aviatrix_vpn_cidr {}
variable aviatrix_vpn_max_conn {}
variable aviatrix_vpn_nat {}

variable aviatrix_vpn_split_tunnel {}
variable aviatrix_vpn_split_tunnel_search_domain_list {}
variable aviatrix_vpn_split_tunnel_additional_cidrs_list {}
variable aviatrix_vpn_split_tunnel_name_servers_list {}

variable aviatrix_single_az_ha {}

variable enable_gov {
  type = bool
  default = false
  description = "Enable to create AWS GovCloud test case"
}
