variable "single_ip_snat" {}
variable "single_az_ha" {}
variable "enable_connected_transit" {}
variable "enable_active_mesh" {}

variable "gcp_gw_size" {}
variable "gcp_ha_gw_size" {
  default = null
}
variable "gcp_ha_gw_zone" {
  default = null
}
variable "gcp_ha_gw_subnet" {
  default = null
}
