resource aviatrix_transit_gateway azure_transit_firenet_gw {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "azure-transit-firenet-gw"
  vpc_id = aviatrix_vpc.azure_transit_firenet_vnet[0].vpc_id
  vpc_reg = aviatrix_vpc.azure_transit_firenet_vnet[0].region
  gw_size = "Standard_B2ms"
  subnet = aviatrix_vpc.azure_transit_firenet_vnet[0].public_subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true
  enable_transit_firenet = true

  lifecycle {
    ignore_changes = [local_as_number]
  }
}

resource aviatrix_transit_gateway azure_egress_firenet_gw {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "azure-egress-firenet-gw"
  vpc_id = aviatrix_vpc.azure_egress_vnet[0].vpc_id
  vpc_reg = aviatrix_vpc.azure_egress_vnet[0].region
  gw_size = "Standard_B2ms"
  subnet = aviatrix_vpc.azure_egress_vnet[0].public_subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true
  enable_transit_firenet = true
  enable_egress_transit_firenet = true
}

resource aviatrix_firewall_instance azure_transit_firenet_instance {
  count = var.enable_azure ? 1 : 0
  vpc_id                = aviatrix_vpc.azure_transit_firenet_vnet[0].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name
  firewall_name         = "azure-tf-instance"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version = "9.1.0"
  firewall_size         = "Standard_D3_v2"
  management_subnet     = aviatrix_vpc.azure_transit_firenet_vnet[0].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.azure_transit_firenet_vnet[0].subnets.1.cidr

  username = "arm-transit-firenet-user"
  password = "ARM-transit-firenet-pa55"
}

resource aviatrix_firewall_instance azure_egress_firenet_instance {
  count = var.enable_azure ? 1 : 0
  vpc_id                = aviatrix_vpc.azure_egress_vnet[0].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.azure_egress_firenet_gw[0].gw_name
  firewall_name         = "azure-egress-instance"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version = "9.1.0"
  firewall_size         = "Standard_D3_v2"
  management_subnet     = aviatrix_vpc.azure_egress_vnet[0].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.azure_egress_vnet[0].subnets.1.cidr

  username = "arm-egress-firenet-user"
  password = "ARM-egress-firenet-pa55"
}

resource aviatrix_firenet azure_transit_firenet_east {
  count = var.enable_azure ? 1 : 0
  vpc_id              = aviatrix_vpc.azure_transit_firenet_vnet[0].vpc_id
  inspection_enabled  = true # default true (reversed if FQDN use case)
  egress_enabled      = false # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.azure_transit_firenet_instance[0].firewall_name
    instance_id           = aviatrix_firewall_instance.azure_transit_firenet_instance[0].instance_id
    lan_interface         = aviatrix_firewall_instance.azure_transit_firenet_instance[0].lan_interface
    management_interface  = aviatrix_firewall_instance.azure_transit_firenet_instance[0].management_interface
    egress_interface      = aviatrix_firewall_instance.azure_transit_firenet_instance[0].egress_interface
    attached              = true # updateable
  }
}

resource aviatrix_firenet azure_egress_firenet_west {
  count = var.enable_azure ? 1 : 0
  vpc_id              = aviatrix_vpc.azure_egress_vnet[0].vpc_id
  inspection_enabled  = false # cannot disable inspection - unsupported for egress transit
  egress_enabled      = true # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.azure_egress_firenet_gw[0].gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.azure_egress_firenet_instance[0].firewall_name
    instance_id           = aviatrix_firewall_instance.azure_egress_firenet_instance[0].instance_id
    lan_interface         = aviatrix_firewall_instance.azure_egress_firenet_instance[0].lan_interface
    management_interface  = aviatrix_firewall_instance.azure_egress_firenet_instance[0].management_interface
    egress_interface      = aviatrix_firewall_instance.azure_egress_firenet_instance[0].egress_interface
    attached              = true # updateable
  }
}

resource aviatrix_transit_firenet_policy azure_transit_firenet_policy_1 {
  count = var.enable_azure ? 1 : 0
  transit_firenet_gateway_name  = aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name
  inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.dual_firenet_azure_spoke_gw_1[0].gw_name])
}

resource aviatrix_transit_firenet_policy azure_transit_firenet_policy_2 {
  count = var.enable_azure ? 1 : 0
  transit_firenet_gateway_name  = aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name
  inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.dual_firenet_azure_spoke_gw_2[0].gw_name])
}
