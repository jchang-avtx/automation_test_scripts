## Create GovCloud simulation (Test case 2)

resource random_integer gov_vpc1_cidr_int {
  count = var.enable_gov ? 2 : 0
  min = 1
  max = 126
}

resource aviatrix_vpc aws_gov_transit_vpc {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 256
  name                  = "aws-gov-transit-vpc"
  region                = "us-gov-east-1"
}

resource aviatrix_transit_gateway aws_gov_tgw_transit_gw {
  count = var.enable_gov ? 1 : 0
  cloud_type                  = 256
  account_name                = "AWSGovRoot"
  gw_name                     = "aws-gov-tgw-transit-gw"
  vpc_id                      = aviatrix_vpc.aws_gov_transit_vpc[0].vpc_id
  vpc_reg                     = aviatrix_vpc.aws_gov_transit_vpc[0].region
  gw_size                     = "t3.small"
  subnet                      = aviatrix_vpc.aws_gov_transit_vpc[0].subnets.4.cidr

  enable_hybrid_connection    = true
  connected_transit           = false
  enable_active_mesh          = false

  # lifecycle {
  #   ignore_changes = [local_as_number] # to be managed by vgw_conn (R2.16 - 6.1)
  # }
}

resource aws_vpn_gateway us_gov_east_vgw {
  count = var.enable_gov ? 1 : 0
  tags = {
    Name = "us-gov-east-vgw"
  }
  amazon_side_asn = 64512
}

resource aviatrix_vgw_conn aws_gov_tgw_vgw_conn {
  count = var.enable_gov ? 1 : 0
  conn_name             = "aws-gov-tgw-vgw-conn"
  gw_name               = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].gw_name
  vpc_id                = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].vpc_id
  bgp_vgw_id            = aws_vpn_gateway.us_gov_east_vgw[0].id
  bgp_vgw_account       = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].account_name
  bgp_vgw_region        = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].vpc_reg
  bgp_local_as_num      = 65001
}

resource aviatrix_aws_tgw aws_gov_tgw {
  count = var.enable_gov ? 1 : 0
  cloud_type                        = 256
  tgw_name                          = "aws-gov-tgw"
  account_name                      = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].account_name
  region                            = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].vpc_reg
  aws_side_as_number                = 4294967294 # 65412
  # attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].gw_name]

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = var.connected_domains_list1
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = var.connected_domains_list2
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = var.connected_domains_list3
  }
  security_domains {
    security_domain_name = var.security_domain_name_list[0]
    connected_domains    = var.connected_domains_list4
  }
  security_domains {
    security_domain_name = var.security_domain_name_list[1]
    aviatrix_firewall    = false
    native_egress        = false
    native_firewall      = false
  }

  manage_vpc_attachment = true
  manage_transit_gateway_attachment = false
  # enable_multicast = true # Mantis (16802) R2.17 - U6.2
  depends_on            = [aviatrix_vgw_conn.aws_gov_tgw_vgw_conn[0]]
}

resource aviatrix_aws_tgw_transit_gateway_attachment aws_gov_tgw_transit_att {
  count = var.enable_gov ? 1 : 0
  tgw_name                = aviatrix_aws_tgw.aws_gov_tgw[0].tgw_name
  region                  = aviatrix_aws_tgw.aws_gov_tgw[0].region
  vpc_account_name        = aviatrix_aws_tgw.aws_gov_tgw[0].account_name
  vpc_id                  = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].vpc_id
  transit_gateway_name    = aviatrix_transit_gateway.aws_gov_tgw_transit_gw[0].gw_name
}

## AWS_TGW_VPN_CONN
# Dynamic connection
resource aviatrix_aws_tgw_vpn_conn aws_gov_tgw_vpn_conn1 {
  count = var.enable_gov ? 1 : 0
  tgw_name             = aviatrix_aws_tgw.aws_gov_tgw[0].tgw_name
  route_domain_name    = "Default_Domain"
  connection_name      = "aws-gov-tgw-vpn-conn1"
  connection_type      = "dynamic"
  public_ip            = "69.0.0.0"
  remote_as_number     = "1234"

  # optional custom tunnel options
  inside_ip_cidr_tun_1 = "169.254.69.69/30" # A /30 CIDR in 169.254.0.0/16
  pre_shared_key_tun_1 = "abc_123.def" # A 8-64 character string with alphanumeric, underscore(_) and dot(.). It cannot start with 0.
  inside_ip_cidr_tun_2 = "169.254.70.70/30"
  pre_shared_key_tun_2 = "def_456.ghi"

  enable_learned_cidrs_approval = var.enable_learned_cidrs_approval

  lifecycle {
    ignore_changes = [pre_shared_key_tun_1, pre_shared_key_tun_2]
  }
}

# Static connection
resource aviatrix_aws_tgw_vpn_conn aws_gov_tgw_vpn_conn2 {
  count = var.enable_gov ? 1 : 0
  tgw_name             = aviatrix_aws_tgw.aws_gov_tgw[0].tgw_name
  route_domain_name    = "Default_Domain"
  connection_name      = "aws-gov-tgw-vpn-conn2"
  connection_type      = "static"
  public_ip            = "70.0.0.0"
  remote_cidr          = "10.0.0.0/16,10.1.0.0/16"

  enable_learned_cidrs_approval = false
}

## OUTPUTS
output aws_gov_tgw_id {
  value = var.enable_gov ? aviatrix_aws_tgw.aws_gov_tgw[0].id : null
}

output aws_gov_tgw_transit_att_id {
  value = var.enable_gov ? aviatrix_aws_tgw_transit_gateway_attachment.aws_gov_tgw_transit_att[0].id : null
}

output aws_gov_tgw_vpn_conn1_id {
  value = var.enable_gov ? aviatrix_aws_tgw_vpn_conn.aws_gov_tgw_vpn_conn1[0].id : null
}

output aws_gov_tgw_vpn_conn2_id {
  value = var.enable_gov ? aviatrix_aws_tgw_vpn_conn.aws_gov_tgw_vpn_conn2[0].id : null
}
