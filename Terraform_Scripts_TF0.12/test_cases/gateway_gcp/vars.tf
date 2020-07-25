variable "enable_ha" {
  default = false
  description = "GCP gateway's HA status"
}

variable "gcp_ha_gw_size" {
  default = null
}
variable "gcp_ha_gw_subnet" {
  default = null
}
variable "gcp_ha_gw_zone" {
  default = null
}
