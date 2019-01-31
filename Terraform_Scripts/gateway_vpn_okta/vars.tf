variable "aws_region" {}
variable "aws_vpc_id" {}
variable "aws_instance" {}
variable "aws_vpc_public_cidr" {}
variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_cloud_account_name" {}
variable "aviatrix_cloud_type_aws" {}
variable "aviatrix_gateway_name" {}

# vpn parameters
variable "aviatrix_vpn_access" {}
variable "aviatrix_vpn_cidr" {}
variable "aviatrix_vpn_elb" {}
variable "aviatrix_vpn_split_tunnel" {}
variable "aviatrix_vpn_otp_mode" {}

# okta parameters
variable "aviatrix_vpn_okta_token" {}
variable "aviatrix_vpn_okta_url" {}
variable "aviatrix_vpn_okta_username_suffix" {}
