variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_aws_access_account" {}

variable "ssh_user" {
  default = "ubuntu"
}
variable "public_key" {}
variable "private_key" {}

variable "edge_domain_connected_list" {}
variable "shared_service_domain_connected_list" {}
variable "dev_domain_connected_list" {}
variable "security_domain_connected_list" {}

variable "bootstrap_role" {}
variable "bootstrap_bucket" {}
