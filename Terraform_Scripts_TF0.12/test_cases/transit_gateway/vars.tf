variable "gw_size" {}

## HA-related parameters
variable "aviatrix_ha_gw_size" {}
variable "single_az_ha" {}

variable "tgw_enable_hybrid" {}
variable "tgw_enable_connected_transit" {}

variable "enable_vpc_dns_server" {}
variable "enable_learned_cidrs_approval" {
  description = "Enable approval requirement for dynamically learned BGP routes from remote site, before being programmed into Spoke VPCs' route table."
  default = true
}

## Custom routes parameters
variable "custom_spoke_vpc_routes" {
  description = "Disable auto route propagation in favor of specified CIDRs for route table"
  default = "13.23.4.4/32,14.23.4.4/32"
}

variable "filter_spoke_vpc_routes" {
  description = "Filter on-prem network CIDR to spoke VPC route table entry. Specify unwanted list of CIDRs"
  default = "14.24.5.5/32"
}

variable "exclude_advertise_spoke_routes" {
  description = "Selectively exclude some VPC CIDRs from being advertised to on-prem."
  default = "14.25.6.6/32,15.25.6.6/32"
}
