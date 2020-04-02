## vpc-attachment-related
variable "tgw_sec_domain" {}
variable "customized_routes" {}
variable "disable_local_route_propagation" {}

## tgw-directconnect-related
variable "prefix" {
  default = "10.12.0.0/24"
}

variable "enable_learned_cidrs_approval" {
  description = "Enable approval requirement for dynamically learned BGP routes from remote site, before being programmed into Spoke VPCs' route table."
  default = true
}
