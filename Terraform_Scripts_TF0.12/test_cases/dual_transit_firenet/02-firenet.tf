resource aviatrix_transit_gateway transit_firenet_gw {
  count = var.enable_aws ? 1 : 0
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "transit-firenet-gw"
  vpc_id = aviatrix_vpc.transit_firenet_vpc[0].vpc_id
  vpc_reg = aviatrix_vpc.transit_firenet_vpc[0].region
  gw_size = "c5.xlarge"
  subnet = aviatrix_vpc.transit_firenet_vpc[0].public_subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true
  enable_transit_firenet = true

  lifecycle {
    ignore_changes = [local_as_number]
  }
}

resource aviatrix_transit_gateway egress_firenet_gw {
  count = var.enable_aws ? 1 : 0
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "egress-firenet-gw"
  vpc_id = aviatrix_vpc.egress_firenet_vpc[0].vpc_id
  vpc_reg = aviatrix_vpc.egress_firenet_vpc[0].region
  gw_size = "c5.xlarge"
  subnet = aviatrix_vpc.egress_firenet_vpc[0].public_subnets.0.cidr

  connected_transit = true
  enable_active_mesh = true
  enable_transit_firenet = true
  enable_egress_transit_firenet = true # to be supported in R2.17
}

resource aviatrix_firewall_instance transit_firenet_instance {
  count = var.enable_aws ? 1 : 0
  vpc_id                = aviatrix_vpc.transit_firenet_vpc[0].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.transit_firenet_gw[0].gw_name
  firewall_name         = "transit-firenet-instance"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version = "9.1.3"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.transit_firenet_vpc[0].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.transit_firenet_vpc[0].subnets.1.cidr
  # key_name              = "randomKeyName.pem"
  iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

resource aviatrix_firewall_instance egress_firenet_instance {
  count = var.enable_aws ? 1 : 0
  vpc_id                = aviatrix_vpc.egress_firenet_vpc[0].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.egress_firenet_gw[0].gw_name
  firewall_name         = "egress-firenet-instance"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version = "9.1.3"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.egress_firenet_vpc[0].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.egress_firenet_vpc[0].subnets.1.cidr
  # key_name              = "randomKeyName.pem"
  iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

resource aviatrix_firenet transit_firenet_east {
  count = var.enable_aws ? 1 : 0
  vpc_id              = aviatrix_vpc.transit_firenet_vpc[0].vpc_id
  inspection_enabled  = true # default true (reversed if FQDN use case)
  egress_enabled      = false # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.transit_firenet_gw[0].gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.transit_firenet_instance[0].firewall_name
    instance_id           = aviatrix_firewall_instance.transit_firenet_instance[0].instance_id
    lan_interface         = aviatrix_firewall_instance.transit_firenet_instance[0].lan_interface
    management_interface  = aviatrix_firewall_instance.transit_firenet_instance[0].management_interface
    egress_interface      = aviatrix_firewall_instance.transit_firenet_instance[0].egress_interface
    attached              = true # updateable
  }
}

resource aviatrix_firenet egress_firenet_west {
  count = var.enable_aws ? 1 : 0
  vpc_id              = aviatrix_vpc.egress_firenet_vpc[0].vpc_id
  inspection_enabled  = false # cannot disable inspection - unsupported for egress transit
  egress_enabled      = true # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.egress_firenet_gw[0].gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.egress_firenet_instance[0].firewall_name
    instance_id           = aviatrix_firewall_instance.egress_firenet_instance[0].instance_id
    lan_interface         = aviatrix_firewall_instance.egress_firenet_instance[0].lan_interface
    management_interface  = aviatrix_firewall_instance.egress_firenet_instance[0].management_interface
    egress_interface      = aviatrix_firewall_instance.egress_firenet_instance[0].egress_interface
    attached              = true # updateable
  }
}

resource aviatrix_transit_firenet_policy transit_firenet_policy_1 {
  count = var.enable_aws ? 1 : 0
  transit_firenet_gateway_name  = aviatrix_transit_gateway.transit_firenet_gw[0].gw_name
  inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.dual_firenet_spoke_gw_1[0].gw_name])
}

resource aviatrix_transit_firenet_policy transit_firenet_policy_2 {
  count = var.enable_aws ? 1 : 0
  transit_firenet_gateway_name  = aviatrix_transit_gateway.transit_firenet_gw[0].gw_name
  inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.dual_firenet_spoke_gw_2[0].gw_name])
}
