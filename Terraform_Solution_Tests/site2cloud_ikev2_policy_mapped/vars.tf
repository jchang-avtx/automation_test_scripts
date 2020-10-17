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
variable "phase_1_authentication" {}
variable "phase_2_authentication" {}
variable "phase_1_dh_groups" {}
variable "phase_2_dh_groups" {}
variable "phase_1_encryption" {}
variable "phase_2_encryption" {}
