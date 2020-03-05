variable "gw_size" {
  default = "c5.large"
}
variable "aviatrix_ha_gw_size" {
  default = "c5.large"
}

variable "active_mesh" {
  default = true
}
variable "aviatrix_transit_gw" {}
variable "enable_vpc_dns_server" {
  default = false
}
