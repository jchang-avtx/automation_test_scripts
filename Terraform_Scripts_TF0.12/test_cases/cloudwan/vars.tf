variable avx_transit_att_status {
  default = false
}

variable aws_tgw_att_status {
  default = false
}

variable azure_virtual_wan_att_status {
  default = false
}

###
variable csr_instance_key {
  type = string
  description = "Specify AWS keypair to use to launch the instance"
}

variable branch_router_key {
  type = string
  description = "Specify full filepath to the key .pem file"
}
