variable "aviatrix_controller_ip" {}
variable "aviatrix_account_username" {}
variable "aviatrix_account_password" {}
variable "aviatrix_fqdn_mode" {}
variable "aviatrix_fqdn_status" {}
variable "aviatrix_fqdn_tag" {}
variable "aviatrix_gateway_list" {
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
