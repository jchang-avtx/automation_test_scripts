variable "regions_list"         {type="list"}
variable "tgw_per_region"       {type="map"}
variable "tgw_max_account"      {}
variable "tgw_account_name"     {}

variable "transit_account"      {}
variable "transit_account_name" {}
variable "account_password"     {} 
variable "aws_account_number"   {}
variable "aws_access_key"       {}
variable "aws_secret_key"       {}
variable "cloud_type"           {}

variable "controller_ip" {}
variable "controller_username" {}
variable "controller_password" {}

variable "transit_gateway_name" {}
variable "transit_gateway_size" {}
variable "transit_subnet" {}
variable "transit_vpc" {}

variable "ondemand_spoke_gateway_size" {}
variable "ondemand_max_account" {}
variable "ondemand_act_name" {}
variable "ondemand_gateway_name" {}
variable "ondemand_spoke_count" {}
variable "ondemand_spoke_cidr_prefix" {}
