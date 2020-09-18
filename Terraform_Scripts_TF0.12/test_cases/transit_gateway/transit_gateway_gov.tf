resource random_integer gov_vpc1_cidr_int {
  count = var.enable_gov ? 2 : 0
  min = 1
  max = 126
}

resource aviatrix_vpc gov_insane_transit_gw_vpc {
  count = var.enable_gov ? 1 : 0
  cloud_type            = 256
  account_name          = "AWSGovRoot"
  region                = "us-gov-east-1"
  name                  = "gov-insane-transit-gw-vpc"
  cidr                  = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource aws_eip gov_eip_aws_transit_gateway {
  count = var.enable_gov ? 1 : 0
  lifecycle {
    ignore_changes = [tags]
  }
}
resource aws_eip gov_eip_aws_transit_gateway_ha {
  count = var.enable_gov ? 1 : 0
  lifecycle {
    ignore_changes = [tags]
  }
}

resource aviatrix_transit_gateway gov_insane_transit_gw {
  count = var.enable_gov ? 1 : 0
  cloud_type          = 256
  account_name        = "AWSGovRoot"
  gw_name             = "gov-insane-transit-gw"

  vpc_id              = aviatrix_vpc.gov_insane_transit_gw_vpc[0].vpc_id
  vpc_reg             = aviatrix_vpc.gov_insane_transit_gw_vpc[0].region
  gw_size             = var.gw_size
  subnet              = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, "1.128/26"])

  single_az_ha        = var.single_az_ha
  insane_mode         = true
  insane_mode_az      = "us-gov-east-1a"
  ha_subnet           = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, "1.192/26"])
  ha_insane_mode_az   = "us-gov-east-1b"
  ha_gw_size          = var.aviatrix_ha_gw_size

  allocate_new_eip    = false
  eip                 = aws_eip.gov_eip_aws_transit_gateway[0].public_ip
  ha_eip              = aws_eip.gov_eip_aws_transit_gateway_ha[0].public_ip

  enable_hybrid_connection  = var.tgw_enable_hybrid
  connected_transit         = var.tgw_enable_connected_transit
  enable_active_mesh        = true
  enable_vpc_dns_server     = var.enable_vpc_dns_server
  enable_learned_cidrs_approval = var.enable_learned_cidrs_approval

  customized_spoke_vpc_routes       = var.custom_spoke_vpc_routes
  filtered_spoke_vpc_routes         = var.filter_spoke_vpc_routes
  excluded_advertised_spoke_routes  = var.exclude_advertise_spoke_routes

  bgp_ecmp            = var.bgp_ecmp_status
  bgp_polling_time    = var.bgp_polling_time
  local_as_number     = var.local_asn
  prepend_as_path     = var.prepend_as_path_list
}

output gov_insane_transit_gw_id {
  value = var.enable_gov ? aviatrix_transit_gateway.gov_insane_transit_gw[0].id : null
}
