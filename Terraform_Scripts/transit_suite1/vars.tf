variable "account_name" {}
variable "account_password" {}
variable "account_email" {}
variable "aws_account_number" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vgw_connection_name" {}
variable "vgw_id" {}
variable "bgp_local_as" {}
variable "controller_ip" {}
variable "controller_username" {}
variable "controller_password" {}
variable "controller_custom_version" {}

variable "transit_gateway_name" {}
variable "transit_gateway_size" {}
variable "transit_cidr_prefix" {}
variable "transit_region" {}
variable "transit_count" {}

variable "shared_gateway_name" {}
variable "shared_gateway_size" {}
variable "shared_cidr_prefix" {}
variable "shared_region" {}
variable "shared_count" {}

variable "spoke_gateway_size" {}

variable "onprem_count" {}
variable "onprem_region" {}
variable "onprem_cidr_prefix" {}
variable "onprem_gateway_name" {}
variable "onprem_gateway_size" {}
variable "s2c_remote_subnet" {}
variable "single_region" {}

