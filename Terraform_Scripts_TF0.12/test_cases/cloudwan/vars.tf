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

###
output csr_branch_router_id {
  value = aviatrix_branch_router_registration.csr_branch_router.id
}

output csr_branch_router_warn_tag_id {
  value = aviatrix_branch_router_tag.csr_branch_router_warn_tag.id
}

output csr_wan_discovery_id {
  value = aviatrix_branch_router_interface_config.csr_wan_discovery.id
}

output csr_transit_att_id {
  value = var.avx_transit_att_status ? aviatrix_branch_router_transit_gateway_attachment.csr_transit_att[0].id : null
}

output csr_tgw_att_id {
  value = var.aws_tgw_att_status ? aviatrix_branch_router_aws_tgw_attachment.csr_tgw_att[0].id : null
}

output csr_virtual_wan_att_id {
  value = var.azure_virtual_wan_att_status ? aviatrix_branch_router_virtual_wan_attachment.csr_virtual_wan_att[0].id : null
}
