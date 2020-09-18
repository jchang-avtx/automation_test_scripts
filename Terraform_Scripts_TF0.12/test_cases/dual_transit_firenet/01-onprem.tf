resource aviatrix_gateway on_prem_gw {
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "dual-on-prem-gw"
  vpc_id = aviatrix_vpc.on_prem_vpc.vpc_id
  vpc_reg = aviatrix_vpc.on_prem_vpc.region
  subnet = aviatrix_vpc.on_prem_vpc.public_subnets.0.cidr
  gw_size = "t3a.small"
}

resource aws_vpn_gateway on_prem_vgw {
  tags = {
    Name = "dual-on-prem-vgw"
  }
  amazon_side_asn = 65514
}

resource aws_vpn_gateway_attachment on_prem_vgw_attach {
  vpc_id = aviatrix_vpc.on_prem_vpc.vpc_id
  vpn_gateway_id = aws_vpn_gateway.on_prem_vgw.id
}

## METHOD 2 by Ryan Liu - create VGW + attach to VPC + enable route propagation on private rtb
resource aws_route_table on_prem_vpc_priv_rtb {
  vpc_id = aviatrix_vpc.on_prem_vpc.vpc_id
  tags = {
    Name = "dual-on-prem-vpc-priv-rtb"
  }
  propagating_vgws = [aws_vpn_gateway.on_prem_vgw.id]
}

resource aviatrix_vgw_conn on_prem_vgw_conn {
  count = var.enable_aws ? 1 : 0
  conn_name = "dual-on-prem-vgw-conn"
  vpc_id = aviatrix_transit_gateway.transit_firenet_gw[0].vpc_id
  gw_name = aviatrix_transit_gateway.transit_firenet_gw[0].gw_name
  bgp_vgw_id = aws_vpn_gateway.on_prem_vgw.id
  bgp_vgw_account = "AWSAccess"
  bgp_vgw_region = "us-east-2"
  bgp_local_as_num = 65411
}

resource aviatrix_transit_external_device_conn azure_ext_conn {
  count = var.enable_azure ? 1 : 0
  connection_type = "bgp"

  connection_name     = "dual-azure-ext-conn"
  vpc_id              = aviatrix_transit_gateway.azure_transit_firenet_gw[0].vpc_id
  gw_name             = aviatrix_transit_gateway.azure_transit_firenet_gw[0].gw_name
  bgp_local_as_num    = 65411

  remote_gateway_ip     = aviatrix_gateway.on_prem_gw.eip
  bgp_remote_as_num     = 65001

  remote_subnet         = null # only for static
  direct_connect        = false # if true, must specify private IP for router/ remote IP
  pre_shared_key        = "abc-123"
  local_tunnel_cidr     = "172.17.11.2/30" # tunnel inside IP addr of transit gw ; Azure only one IP Addr
  remote_tunnel_cidr    = "172.17.11.1/30" # tunnel inside IP addr of external dev ; Azure only one IP Addr

  custom_algorithms = true
  phase_1_authentication        = "SHA-512" # SHA-256 , SHA-512
  phase_1_dh_groups             = "1" # 14 , 1
  phase_1_encryption            = "AES-192-CBC" # AES-256-CBC , AES-192-CBC
  phase_2_authentication        = "HMAC-SHA-512" # HMAC-SHA-256 , HMAC-SHA-512
  phase_2_dh_groups             = "1" # 14 , 1
  phase_2_encryption            = "AES-192-CBC" # AES-256-CBC , AES-192-CBC

  ha_enabled = false

  lifecycle {
    ignore_changes = [pre_shared_key]
  }
}
