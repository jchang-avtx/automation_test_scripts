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

variable "adv_subnets" {
  default = "subnet-05827995c52de2d76"
}
variable "adv_rtb" {
  default = "rtb-024a3b4ff2b9cf333"
}
variable "adv_custom_route_advertisement" {
  default = "10.60.0.0/24"
}
