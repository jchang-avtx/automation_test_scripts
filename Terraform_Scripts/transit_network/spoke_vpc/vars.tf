variable "aviatrix_cloud_type_aws" {}
variable "aviatrix_cloud_account_name" {}
variable "aviatrix_gateway_name" {}

variable "aws_vpc_id" {}
variable "aws_region" {}
variable "aws_instance" {}
variable "aws_vpc_public_cidr" {}

variable "aviatrix_ha_subnet" {}
variable "aviatrix_ha_gw_size" {}

variable "aviatrix_enable_nat" {}
variable "aviatrix_transit_gw" {} # comment out if want to test Update from no transitGW attach to yes
variable "tag_list" {
  type = "list"
}
