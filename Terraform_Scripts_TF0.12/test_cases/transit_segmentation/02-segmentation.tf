## Transit
resource random_pet pet_transit_gw {
  count = 3
  separator = "-"
  length = 2
}

resource aviatrix_transit_gateway aws_segment_transit_gw {
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "segment-transit-gw-${random_pet.pet_transit_gw[0].id}"
  vpc_id = aviatrix_vpc.aws_segment_transit_vpc.vpc_id
  vpc_reg = aviatrix_vpc.aws_segment_transit_vpc.region
  gw_size = "t3a.small"
  subnet = aviatrix_vpc.aws_segment_transit_vpc.public_subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true # must be enabled for segmentation
  enable_segmentation = true
}

## Azure
resource aviatrix_transit_gateway arm_segment_transit_gw {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "segment-transit-gw-${random_pet.pet_transit_gw[1].id}"
  vpc_id = aviatrix_vpc.arm_segment_transit_vnet[0].vpc_id
  vpc_reg = aviatrix_vpc.arm_segment_transit_vnet[0].region
  gw_size = "Standard_B1ms"
  subnet = aviatrix_vpc.arm_segment_transit_vnet[0].public_subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true # must be enabled for segmentation
  enable_segmentation = true
}

resource aviatrix_transit_gateway_peering aws_arm_transit_peer {
  count = var.enable_azure ? 1 : 0
  transit_gateway_name1 = aviatrix_transit_gateway.aws_segment_transit_gw.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.arm_segment_transit_gw[0].gw_name
}

## GCP
resource aviatrix_transit_gateway gcp_segment_transit_gw {
  count = var.enable_gcp ? 1 : 0
  cloud_type = 4
  account_name = "GCPAccess"
  gw_name = "segment-transit-gw-${random_pet.pet_transit_gw[2].id}"
  vpc_id = aviatrix_vpc.gcp_segment_vpc[0].vpc_id
  vpc_reg = "${aviatrix_vpc.gcp_segment_vpc[0].subnets.0.region}-b"
  gw_size = "n1-standard-1"
  subnet = aviatrix_vpc.gcp_segment_vpc[0].subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true # must be enabled for segmentation
  enable_segmentation = true
}

resource aviatrix_transit_gateway_peering gcp_aws_transit_peer {
  count = var.enable_gcp ? 1 : 0
  transit_gateway_name1 = aviatrix_transit_gateway.gcp_segment_transit_gw[0].gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.aws_segment_transit_gw.gw_name
}

###############################################################################
## Segmentation

resource aviatrix_segmentation_security_domain segment_dom_blue {
  domain_name = "segment-dom-blue"
}

resource aviatrix_segmentation_security_domain segment_dom_green {
  domain_name = "segment-dom-green"
}

resource aviatrix_segmentation_security_domain_connection_policy dom_blue_green_associate {
  domain_name_1 = aviatrix_segmentation_security_domain.segment_dom_blue.id
  domain_name_2 = aviatrix_segmentation_security_domain.segment_dom_green.id
}

resource aviatrix_segmentation_security_domain_association spoke_blue_associate {
  transit_gateway_name = aviatrix_transit_gateway.aws_segment_transit_gw.gw_name
  security_domain_name = aviatrix_segmentation_security_domain.segment_dom_blue.id
  attachment_name = aviatrix_spoke_gateway.aws_segment_spoke_gw["eu-central-1"].gw_name
}

resource aviatrix_segmentation_security_domain_association spoke_green_associate {
  transit_gateway_name = aviatrix_transit_gateway.aws_segment_transit_gw.gw_name
  security_domain_name = aviatrix_segmentation_security_domain.segment_dom_green.id
  attachment_name = aviatrix_spoke_gateway.aws_segment_spoke_gw["eu-west-1"].gw_name
}

resource aviatrix_segmentation_security_domain_association arm_spoke_blue_associate {
  count = var.enable_azure ? 1 : 0
  transit_gateway_name = aviatrix_transit_gateway.arm_segment_transit_gw[0].gw_name
  security_domain_name = aviatrix_segmentation_security_domain.segment_dom_blue.id
  attachment_name = aviatrix_spoke_gateway.arm_segment_spoke_gw[0].gw_name
}

resource aviatrix_segmentation_security_domain_association gcp_spoke_green_associate {
  count = var.enable_gcp ? 1 : 0
  transit_gateway_name = aviatrix_transit_gateway.gcp_segment_transit_gw[0].gw_name
  security_domain_name = aviatrix_segmentation_security_domain.segment_dom_green.id
  attachment_name = aviatrix_spoke_gateway.gcp_segment_spoke_gw[0].gw_name
}
