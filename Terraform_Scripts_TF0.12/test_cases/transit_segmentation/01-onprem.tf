resource aviatrix_gateway on_prem_gw {
  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "segment-on-prem-gw"
  vpc_id = aviatrix_vpc.on_prem_vpc.vpc_id
  vpc_reg = aviatrix_vpc.on_prem_vpc.region
  subnet = aviatrix_vpc.on_prem_vpc.public_subnets.0.cidr
  gw_size = "t3a.small"
}

resource aws_vpn_gateway on_prem_vgw {
  tags = {
    Name = "segment-on-prem-vgw"
  }
  amazon_side_asn = 65515
}

resource aws_vpn_gateway_attachment on_prem_vgw_attach {
  vpc_id = aviatrix_vpc.on_prem_vpc.vpc_id
  vpn_gateway_id = aws_vpn_gateway.on_prem_vgw.id
}

## METHOD 2 by Ryan Liu - create VGW + attach to VPC + enable route propagation on private rtb
resource aws_route_table on_prem_vpc_priv_rtb {
  vpc_id = aviatrix_vpc.on_prem_vpc.vpc_id
  tags = {
    Name = "segment-on-prem-vpc-priv-rtb"
  }
  propagating_vgws = [aws_vpn_gateway.on_prem_vgw.id]
}

resource aviatrix_vgw_conn on_prem_vgw_conn {
  conn_name = "segment-on-prem-vgw-conn"
  vpc_id = aviatrix_transit_gateway.aws_segment_transit_gw.vpc_id
  gw_name = aviatrix_transit_gateway.aws_segment_transit_gw.gw_name
  bgp_vgw_id = aws_vpn_gateway.on_prem_vgw.id
  bgp_vgw_account = "AWSAccess"
  bgp_vgw_region = "us-east-2"
  bgp_local_as_num = 65410
}
