# Variable declarations for testbed-onprem-existing-vpc module
variable "resource_name_label" {
  type        = string
  description = "Resource name label."
}

variable "gw_name" {
  type        = string
  description = "Name of Aviatrix Onprem GW. Default is 'onprem-gw'."
  default     = "onprem-gw"
}

variable "s2c_connection_name" {
  type        = string
  description = "Name of onprem S2C connection. Default is 'onprem-s2c'."
  default     = "onprem-s2c"
}

variable "account_name" {
  type        = string
  description = "Access account name in Aviatrix controller."
}

variable "onprem_vpc_id" {
  type        = string
  description = "VPC id for Onprem VPC."
}

variable "pub_subnet_cidr" {
  type        = string
  description = "Subnet cidr to launch Aviatrix GW and public ubuntu instance into."
}

variable "remote_subnet_cidr" {
  type        = list(string)
  description = "Remote subnet cidr for Site2Cloud connection."
}

variable "local_subnet_cidr" {
  type        = list(string)
  description = "Local subnet cidr for Site2Cloud connection. Optional."
  default     = []
}

variable "static_route_cidr" {
  type        = list(string)
  description = "List of static routes to add to VPN."
}

variable "asn" {
  type        = number
  description = "ASN for the AWS VGW. If you don't specift an ASN, the VGW is created with the default ASN."
  default     = null
}
