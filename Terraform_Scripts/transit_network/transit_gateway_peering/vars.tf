variable "aviatrix_transit_gateway_1" {}
variable "aviatrix_transit_gateway_2" {}

## Transit GW-related variables
variable "aviatrix_cloud_type_aws" {}
variable "aviatrix_cloud_account_name" {}
variable "aviatrix_enable_nat" {}

variable "aws_vpc_id" {
  type = "list"
}
variable "aws_region" {
  type = "list"
}
variable "aws_instance" {}
variable "aws_vpc_public_cidr" {
  type = "list"
}

## side note: HA-related parameters are removed for the sake of testing speed
variable "tag_list" {
  type = "list"
}
variable "tgw_enable_hybrid" {}
variable "tgw_enable_connected_transit" {}
