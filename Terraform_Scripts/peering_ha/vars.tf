variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "aviatrix_cloud_account_name" {}
variable "aviatrix_cloud_type_aws" {}

variable "gateway_names" { type = "list" }
variable "aws_vpc_id" { type = "list" }
variable "aws_vpc_public_cidr" { type = "list" }
variable "aws_region" {}
variable "aws_instance" {}

variable "enable_ha" {}
variable "enable_cluster" {}
