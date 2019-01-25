# variable "aviatrix_controller_ip" {}
# variable "aviatrix_controller_username" {}
# variable "aviatrix_controller_password" {}

variable "aws_region" {
  type = "list"
}
variable "aws_vpc_id" {
  type = "list"
}
variable "aws_instance" {
  type = "list"
}
variable "aws_vpc_public_cidr" {
  type = "list"
}
variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_cloud_account_name" {}
variable "aviatrix_gateway_name" {
  type = "list"
}
variable "aviatrix_cloud_type_aws" {}
