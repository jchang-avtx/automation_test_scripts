variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "aviatrix_tgw_name" {}
variable "aviatrix_cloud_account_name" {}
variable "aviatrix_tgw_region" {}

variable "aws_bgp_asn" {}
# variable "aviatrix_attached_transit_gw" {
#   type = "list"
# }

variable "security_domain_name_list" {
  type = "list"
}
variable "connected_domains_list1" {
  type = "list"
}
variable "connected_domains_list2" {
  type = "list"
}
variable "connected_domains_list3" {
  type = "list"
}
variable "connected_domains_list4" {
  type = "list"
}

## attached_vpc parameters
# refers to the vpc_region; must be consistent with AWS TGW region
variable "aws_region" {
  type = "list"
}
variable "aviatrix_cloud_account_name_list" {
  type = "list"
}
variable "aws_vpc_id" {
  type = "list"
}
