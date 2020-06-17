variable "gcp_instance_size" {}

variable "gcp_ha_gw_size" {
  default = null
}
variable "gcp_ha_gw_zone" {
  default = null
}
variable "gcp_ha_gw_subnet" {
  default = null
}

variable "toggle_snat" {}
variable "attached_transit_gw" {
  default = null
}
