## vpc-attachment-related
variable "tgw_sec_domain" {}
variable "customized_routes" {}
variable "disable_local_route_propagation" {}

## tgw-directconnect-related
variable "prefix" {
  default = "10.12.0.0/24"
}
