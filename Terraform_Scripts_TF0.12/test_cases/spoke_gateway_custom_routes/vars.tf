variable "custom_spoke_vpc_routes" {
  description = "Disable auto route propagation in favor of specified CIDRs for route table"
  default = "13.23.4.4/32,14.23.4.4/32"
}

variable "filter_spoke_vpc_routes" {
  description = "Filter on-prem network CIDR to spoke VPC route table entry. Specify unwanted list of CIDRs"
  default = "14.24.5.5/32"
}

variable "include_advertise_spoke_routes" {
  description = "Selectively exclude some VPC CIDRs from being advertised to on-prem."
  default = "14.25.6.6/32,15.25.6.6/32"
}
