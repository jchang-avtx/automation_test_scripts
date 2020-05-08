variable "conn_type" {
  description = "Select BGP if the Transit GW runs dynamic routing with remote site. Otherwise, select Static."
  default = "bgp"
}

variable "dxc_status" {
  description = "If infrastructure is private network, eg. AWS DxC and ARM ExpressRoute, set true. BGP and IPSEC will then run over private IP addresses."
  default = false
}
