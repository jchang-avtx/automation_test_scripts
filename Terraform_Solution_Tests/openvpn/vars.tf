# Aviatrix
variable "avx_aws_access_account_name" {}
variable "avx_vpn_cidr" {
  default = "192.168.43.0/24"
}

# AWS
variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

# Credentials
variable "ssh_user" {
  default = "ubuntu"
}
variable "public_key" {}
variable "private_key" {}
