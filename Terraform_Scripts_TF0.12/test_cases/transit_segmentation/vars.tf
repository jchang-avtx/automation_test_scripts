variable enable_azure {
  type = bool
  description = "Set to true to build test case for Azure transit segmentation"
  default = false
}

variable enable_gcp {
  type = bool
  description = "Set to true to build test case for GCP transit segmentation"
  default = false
}

## Outputs
output aws_segment_transit_gw_id {
  value = aviatrix_transit_gateway.aws_segment_transit_gw.id
}

output arm_segment_transit_gw_id {
  value = var.enable_azure ? aviatrix_transit_gateway.arm_segment_transit_gw[0].id : null
}

output gcp_segment_transit_gw_id {
  value = var.enable_gcp ? aviatrix_transit_gateway.gcp_segment_transit_gw[0].id : null
}

output aws_arm_transit_peer_id {
  value = var.enable_azure ? aviatrix_transit_gateway_peering.aws_arm_transit_peer[0].id : null
}

output gcp_aws_transit_peer_id {
  value = var.enable_gcp ? aviatrix_transit_gateway_peering.gcp_aws_transit_peer[0].id : null
}

output segment_dom_blue_id {
  value = aviatrix_segmentation_security_domain.segment_dom_blue.id
}

output segment_dom_green_id {
  value = aviatrix_segmentation_security_domain.segment_dom_green.id
}

output dom_blue_green_associate_id {
  value = aviatrix_segmentation_security_domain_connection_policy.dom_blue_green_associate.id
}

output spoke_blue_associate_id {
  value = aviatrix_segmentation_security_domain_association.spoke_blue_associate.id
}

output spoke_green_associate_id {
  value = aviatrix_segmentation_security_domain_association.spoke_green_associate.id
}

output arm_spoke_blue_associate_id {
  value = var.enable_azure ? aviatrix_segmentation_security_domain_association.arm_spoke_blue_associate[0].id : null
}

output gcp_spoke_green_associate_id {
  value = var.enable_gcp ? aviatrix_segmentation_security_domain_association.gcp_spoke_green_associate[0].id : null
}
