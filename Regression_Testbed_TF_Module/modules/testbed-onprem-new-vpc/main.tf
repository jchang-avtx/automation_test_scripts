# Main.tf for testbed-onprem module
data "aws_region" "current" {}

resource "aws_vpc" "onprem_vpc" {
	cidr_block	= var.onprem_vpc_cidr

	tags	= {
		Name			= "${var.resource_name_label}-onprem-vpc-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "aws_subnet" "public_subnet" {
	vpc_id						= aws_vpc.onprem_vpc.id
	cidr_block				= var.pub_subnet_cidr
	availability_zone = var.pub_subnet_az != null ? var.pub_subnet_az : ""

	tags	= {
		Name			= var.pub_subnet_az != null ? "${var.resource_name_label}-onprem-public-subnet-${var.pub_subnet_az}" : "${var.resource_name_label}-onprem-public-subnet-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "aws_subnet" "private_subnet" {
	vpc_id						= aws_vpc.onprem_vpc.id
	cidr_block				= var.pri_subnet_cidr
	availability_zone = var.pri_subnet_az != null ? var.pri_subnet_az : ""

	tags	= {
		Name			= var.pri_subnet_az != null ? "${var.resource_name_label}-onprem-private-subnet-${var.pri_subnet_az}" : "${var.resource_name_label}-onprem-private-subnet-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.onprem_vpc.id

	tags = {
		Name 			= "${var.resource_name_label}-onprem-igw-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "aws_route_table" "public_rtb" {
	vpc_id				= aws_vpc.onprem_vpc.id

	route {
		cidr_block	= "0.0.0.0/0"
		gateway_id	= aws_internet_gateway.igw.id
	}

	lifecycle {
		ignore_changes = all
	}

	tags = {
		Name 			= "${var.resource_name_label}-onprem-public-rtb-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "aws_route_table" "private_rtb" {
	vpc_id				= aws_vpc.onprem_vpc.id

	lifecycle {
		ignore_changes = all
	}

	tags = {
		Name 			= "${var.resource_name_label}-onprem-private-rtb-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "aws_route_table_association" "public_rtb_associate" {
	subnet_id				= aws_subnet.public_subnet.id
	route_table_id	= aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_rtb_associate" {
	subnet_id				= aws_subnet.private_subnet.id
	route_table_id	= aws_route_table.private_rtb.id
}

resource "aws_security_group" "sg" {
	name				= "onprem_allow_ssh_and_icmp"
	description	= "Allow SSH connection and ICMP to ubuntu instances."
	vpc_id			= aws_vpc.onprem_vpc.id

	ingress {
	# SSH
	from_port		= 22
	to_port			= 22
	protocol		= "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
	# ICMP
	from_port		= -1
	to_port			=	-1
	protocol		= "icmp"
	cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
	# Allow all
	from_port 	= 0
	to_port 		= 0
	protocol 		= "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}

	tags	= {
		Name			= "${var.resource_name_label}-onprem-security-group-${data.aws_region.current.name}"
		Owner 		= var.owner
	}
}

resource "random_id" "key_id" {
	byte_length = 4
}

# Key pair is used for all ubuntu instances
resource "aws_key_pair" "key_pair" {
	key_name				= "${var.resource_name_label}-onprem-ubuntu-key-${random_id.key_id.dec}"
	public_key			= var.public_key
}

resource "aws_instance" "public_instance" {
	# Ubuntu
	ami													= var.ubuntu_ami != null ? var.ubuntu_ami : local.ubuntu_ami[data.aws_region.current.name]
	instance_type								= "t2.micro"
	disable_api_termination			= var.termination_protection
	associate_public_ip_address = true
	subnet_id										= aws_subnet.public_subnet.id
	private_ip									= cidrhost(aws_subnet.public_subnet.cidr_block, var.pub_hostnum)
	vpc_security_group_ids			= [aws_security_group.sg.id]
	key_name										= aws_key_pair.key_pair.key_name

	tags	= {
		Name			= "${var.resource_name_label}-onprem-public-ubuntu-${aws_subnet.public_subnet.availability_zone}"
		Owner 		= var.owner
	}
}

resource "aws_eip" "eip" {
	instance	= aws_instance.public_instance.id
	vpc				= true
	tags	= {
		Name		= "${var.resource_name_label}-onprem-public-instance-eip-${data.aws_region.current.name}"
		Owner 	= var.owner
	}
}

resource "aws_instance" "private_instance" {
	# Ubuntu
	ami													= var.ubuntu_ami != null ? var.ubuntu_ami : local.ubuntu_ami[data.aws_region.current.name]
  instance_type               = "t2.micro"
	disable_api_termination     = var.termination_protection
  subnet_id                   = aws_subnet.private_subnet.id
	private_ip									= cidrhost(aws_subnet.private_subnet.cidr_block, var.pri_hostnum)
	vpc_security_group_ids			= [aws_security_group.sg.id]
	key_name										= aws_key_pair.key_pair.key_name

  tags  = {
    Name        = "${var.resource_name_label}-onprem-private-ubuntu-${aws_subnet.private_subnet.availability_zone}"
		Owner 			= var.owner
  }
}

resource "aviatrix_gateway" "avtx_gw" {
    cloud_type          = 1
    account_name        = var.account_name
    gw_name             = "${var.resource_name_label}-${var.gw_name}"
    vpc_id              = aws_vpc.onprem_vpc.id
    vpc_reg             = data.aws_region.current.name
    gw_size             = "t3.micro"
    subnet              = aws_subnet.public_subnet.cidr_block
    enable_snat         = true
}

resource "aws_customer_gateway" "aws_cgw" {
  bgp_asn     = 65000
  ip_address  = aviatrix_gateway.avtx_gw.public_ip
  type        = "ipsec.1"

  tags  = {
    Name 	= "${var.resource_name_label}-main-cgw-${data.aws_region.current.name}"
		Owner = var.owner
  }
}

resource "aws_vpn_gateway" "aws_vgw" {
    amazon_side_asn = var.asn

    tags  = {
      Name 	= "${var.resource_name_label}-onprem-vgw-${data.aws_region.current.name}"
			Owner = var.owner
    }
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.aws_cgw.id
  vpn_gateway_id      = aws_vpn_gateway.aws_vgw.id
	static_routes_only 	= true
  type                = "ipsec.1"

	tags = {
		Name 	= "${var.resource_name_label}-onprem-vpn-${data.aws_region.current.name}"
		Owner = var.owner
	}
}

resource "aws_vpn_connection_route" "route" {
  count                  = length(var.static_route_cidr)
  vpn_connection_id      = aws_vpn_connection.vpn.id
  destination_cidr_block = var.static_route_cidr[count.index]
}

resource "aviatrix_site2cloud" "onprem_s2c" {
  vpc_id  											= aws_vpc.onprem_vpc.id
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
