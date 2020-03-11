# Main.tf for testbed-onprem module
data "aws_region" "current" {}

resource "aviatrix_gateway" "avtx_gw" {
    cloud_type          = 1
    account_name        = var.account_name
    gw_name             = "${var.resource_name_label}-${var.gw_name}"
    vpc_id              = var.onprem_vpc_id
    vpc_reg             = data.aws_region.current.name
    gw_size             = "t3.micro"
    subnet              = var.pub_subnet_cidr
    single_ip_snat      = true
}

resource "aws_customer_gateway" "aws_cgw" {
  bgp_asn     = 65000
  ip_address  = aviatrix_gateway.avtx_gw.public_ip
  type        = "ipsec.1"

  tags  = {
    Name  = "${var.resource_name_label}-main-cgw-${data.aws_region.current.name}"
    Owner = var.owner
  }
}

resource "aws_vpn_gateway" "aws_vgw" {
    amazon_side_asn = var.asn

    tags  = {
      Name  = "${var.resource_name_label}-main-vgw-${data.aws_region.current.name}"
      Owner = var.owner
    }
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.aws_cgw.id
  vpn_gateway_id      = aws_vpn_gateway.aws_vgw.id
	static_routes_only 	= true
  type                = "ipsec.1"

	tags = {
		Name 	= "${var.resource_name_label}-main-vpn-${data.aws_region.current.name}"
    Owner = var.owner
	}
}

resource "aws_vpn_connection_route" "route" {
  count                  = length(var.static_route_cidr)
  vpn_connection_id      = aws_vpn_connection.vpn.id
  destination_cidr_block = var.static_route_cidr[count.index]
}

resource "aviatrix_site2cloud" "onprem_s2c" {
  vpc_id  											= var.onprem_vpc_id
  connection_name   						= "${var.resource_name_label}-${var.s2c_connection_name}"
  connection_type   						= "unmapped"
  remote_gateway_type  					= "generic"
  tunnel_type   								= "udp"
  primary_cloud_gateway_name  	= aviatrix_gateway.avtx_gw.gw_name
  remote_gateway_ip   					= aws_vpn_connection.vpn.tunnel1_address
  pre_shared_key                = aws_vpn_connection.vpn.tunnel1_preshared_key
  remote_subnet_cidr  					= join(",", var.remote_subnet_cidr)
  local_subnet_cidr   					= join(",", var.local_subnet_cidr)
}
