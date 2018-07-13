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
variable "transit_vpc" {}
variable "transit_subnet" {}

variable "shared_gateway_name" {}
variable "shared_gateway_size" {}
variable "shared_vpc" {}
variable "shared_subnet" {}

variable "single_region" {}
variable "spoke_gateway_size" {}
variable "spoke_gateway_prefix" {}

variable "spoke0_vpc" {}
variable "spoke0_subnet" {}

variable "spoke1_vpc" {}
variable "spoke1_subnet" {}

variable "spoke2_vpc" {}
variable "spoke2_subnet" {}

variable "onprem_vpc" {}
variable "onprem_subnet" {}
variable "onprem_gateway_name" {}
variable "onprem_gateway_size" {}
variable "s2c_remote_subnet" {}

variable "azure_region" {}
variable "azure_vpc" {}
variable "azure_subnet" {}
variable "azure_account_name" {}

