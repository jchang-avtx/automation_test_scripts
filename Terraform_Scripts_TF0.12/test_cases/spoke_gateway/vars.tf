variable gw_size {
  default = "c5.large"
}
variable aviatrix_ha_gw_size {
  default = "c5.large"
}

variable active_mesh {
  default = true
}
variable aviatrix_transit_gw {}
variable enable_vpc_dns_server {
  default = false
}

variable enable_gov {
  type = bool
  default = false
  description = "Enable to create AWS GovCloud test case"
}
variable gov_attach_transit_gw {
  description = "List of USGov transit gateways to attach to USGov spoke, in comma-separated string format."
}
