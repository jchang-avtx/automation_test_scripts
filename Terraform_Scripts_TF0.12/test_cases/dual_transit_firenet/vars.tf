variable enable_aws {
  type = bool
  description = "Set to true to create AWS Dual Transit FireNet"
  default = false
}

variable enable_azure {
  type = bool
  description = "Set to true to create Azure Dual Transit FireNet"
  default = false
}

output transit_firenet_gw_id {
  value = var.enable_aws ? aviatrix_transit_gateway.transit_firenet_gw[0].id : null
}

output egress_firenet_gw_id {
  value = var.enable_aws ? aviatrix_transit_gateway.egress_firenet_gw[0].id : null
}

output azure_transit_firenet_gw_id {
  value = var.enable_azure ? aviatrix_transit_gateway.azure_transit_firenet_gw[0].id : null
}

output azure_egress_firenet_gw_id {
  value = var.enable_azure ? aviatrix_transit_gateway.azure_egress_firenet_gw[0].id : null
}
