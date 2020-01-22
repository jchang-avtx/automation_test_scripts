## TGW-related
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
variable "aws_vpc_id" {
  type = "list"
}
variable "custom_routes_list" {}
variable "disable_local_route_propagation" {}
