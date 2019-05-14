variable "aviatrix_cloud_account_name" {}
variable "aviatrix_gateway_name" {}
variable "aviatrix_cloud_type_aws" {}

variable "aws_region" {}
variable "aws_vpc_id" {}
variable "aws_instance" {}
variable "aws_vpc_public_cidr" {}

variable "aviatrix_single_az_ha" {} # comment out if testing Additional#1 or disabling single_az_ha
variable "aws_gateway_tag_list" {
  type = "list"
}
