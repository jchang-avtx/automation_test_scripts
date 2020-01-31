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

variable "pre_shared_key" {}
variable "pre_shared_key_backup" {}
