variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "aviatrix_fqdn_mode" {}
variable "aviatrix_fqdn_status" {}
variable "aviatrix_fqdn_tag" {}
variable "aviatrix_fqdn_gateway" {}

variable "aviatrix_fqdn_source_ip_list" {
  type = "list"
}
variable "aviatrix_fqdn_domain" {
  type = "list"
}
variable "aviatrix_fqdn_protocol" {
  type = "list"
}
variable "aviatrix_fqdn_port" {
  type = "list"
}
