variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "aviatrix_cloud_type_aws" {}
variable "aviatrix_cloud_account_name" {}
variable "aviatrix_gateway_name" {}

variable "aws_vpc_id" {}
variable "aws_region" {}
variable "aws_instance" {}
variable "aws_vpc_public_cidr" {}

## HA-related parameters
variable "aviatrix_ha_subnet" {}
variable "aviatrix_ha_gw_size" {}

variable "tag_list" {
  type = "list"
}
variable "tgw_enable_hybrid" {}
