variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_aws_access_account" {}

variable "aviatrix_fqdn_mode" {}
variable "aviatrix_fqdn_status" {}
variable "aviatrix_fqdn_tag" {}
variable "aviatrix_fqdn_gateway" {}

variable "aviatrix_fqdn_source_ip_list" {
  type = list(string)
}
variable "aviatrix_fqdn_domain" {
  type = list(string)
}
variable "aviatrix_fqdn_protocol" {
  type = list(string)
}
variable "aviatrix_fqdn_port" {
  type = list(string)
}

variable "ssh_user" {
  default = "ubuntu"
}
variable "public_key" {}
variable "private_key" {}

