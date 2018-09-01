#########################
##### AWS resources #####
#########################

## Security Group OnPrem Side
## -----------------------------------
resource "aws_security_group" "allow-ssh-ping-Prem" {
  vpc_id = "${aws_vpc.OnPrem-VPC.id}"
  name = "allow-ssh-onprem"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow-ssh-ping-onprem"
  }
}
## END -------------------------------

## Create OnPrem VPC
## -----------------------------------
# Internet VPC
resource "aws_vpc" "OnPrem-VPC" {
    cidr_block = "${var.aws_vpc_public_cidr}"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "OnPrem-VPC-${var.aws_region}"
    }
}
# Subnets
resource "aws_subnet" "OnPrem-VPC-public" {
    vpc_id = "${aws_vpc.OnPrem-VPC.id}"
    cidr_block = "${var.aws_vpc_public_cidr}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "OnPrem-VPC-public-${var.aws_region}"
    }
}
# Internet GW
resource "aws_internet_gateway" "OnPrem-VPC-gw" {
    vpc_id = "${aws_vpc.OnPrem-VPC.id}"
    tags {
        Name = "OnPrem-VPC-gw-${var.aws_region}"
    }
}
# route tables
resource "aws_route_table" "OnPrem-VPC-route" {
    vpc_id = "${aws_vpc.OnPrem-VPC.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.OnPrem-VPC-gw.id}"
    }
    tags {
        Name = "OnPrem-VPC-route-${var.aws_region}"
    }
}
# route associations public
resource "aws_route_table_association" "OnPrem-VPC-ra" {
    subnet_id = "${aws_subnet.OnPrem-VPC-public.id}"
    route_table_id = "${aws_route_table.OnPrem-VPC-route.id}"
    depends_on = ["aws_subnet.OnPrem-VPC-public","aws_route_table.OnPrem-VPC-route","aws_internet_gateway.OnPrem-VPC-gw","aws_vpc.OnPrem-VPC"]
}
## END -------------------------------


## Create AWS customer gateway & VGW towards aviatrix OnPrem Gateway
## -----------------------------------------------------------------
resource "aws_customer_gateway" "customer_gateway1" {
    bgp_asn    = 6588
    ip_address = "${aviatrix_gateway.OnPrem-GW.public_ip}"
    type       = "ipsec.1"
    tags {
       Name = "onprem-gateway"
    }
}
resource "aws_customer_gateway" "customer_gateway2" {
    bgp_asn    = 6590
    ip_address = "${aviatrix_gateway.OnPrem-GW.backup_public_ip}"
    type       = "ipsec.1"
    tags {
       Name = "aviatrix-customer-gateway2"
    }
    depends_on = ["aviatrix_gateway.OnPrem-GW"]
}
resource "aws_vpn_connection" "vpn1" {
    vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
    customer_gateway_id = "${aws_customer_gateway.customer_gateway1.id}"
    type                = "ipsec.1"
    static_routes_only  = true
    tags {
       Name = "site2cloud-to-vgw-connection1"
    }
}
resource "aws_vpn_connection" "vpn2" {
    vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
    customer_gateway_id = "${aws_customer_gateway.customer_gateway2.id}"
    type                = "ipsec.1"
    static_routes_only  = true
    tags {
       Name = "site2cloud-to-vgw-connection2"
    }
}


# original onprem CIDR block
resource "aws_vpn_connection_route" "onprem1" {
    destination_cidr_block = "${aws_subnet.OnPrem-VPC-public.cidr_block}"
    vpn_connection_id = "${aws_vpn_connection.vpn1.id}"
}
# 2nd static route from onprem 
resource "aws_vpn_connection_route" "onprem2" {
    destination_cidr_block = "100.100.100.0/24"
    vpn_connection_id = "${aws_vpn_connection.vpn2.id}"
}

## END -------------------------------
