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

# duo parameters
variable "aviatrix_vpn_duo_integration_key" {}
variable "aviatrix_vpn_duo_secret_key" {}
variable "aviatrix_vpn_duo_api_hostname" {}
variable "aviatrix_vpn_duo_push_mode" {}

# ldap parameters
variable "aviatrix_vpn_ldap_enable" {}
variable "aviatrix_vpn_ldap_server" {}
variable "aviatrix_vpn_ldap_bind_dn" {}
variable "aviatrix_vpn_ldap_password" {}
variable "aviatrix_vpn_ldap_base_dn" {}
variable "aviatrix_vpn_ldap_username_attribute" {}

