# AWS Transit VPCs
data "aws_availability_zones" "available" {}

resource "aws_vpc" "transit-VPC" {
    cidr_block           = "${var.mod_transit_cidr_prefix}.251.0/24"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"
    tags { Name = "transit-${var.mod_name_suffix}" }
}

# AWS Public Subnets
    #map_public_ip_on_launch = "true"
    #availability_zone = "${data.aws_availability_zones.available.names}"
    #tags { Name = "transit-VPC-public-${var.mod_name_suffix}" }
resource "aws_subnet" "transit-VPC-public-subnet" {
    vpc_id      = "${aws_vpc.transit-VPC.id}"
    cidr_block  = "${var.mod_transit_cidr_prefix}.251.0/28"
}
# AWS Internet GW
resource "aws_internet_gateway" "transit-VPC-gw" {
    vpc_id      = "${aws_vpc.transit-VPC.id}"
    tags { Name = "transit-VPC-gw-${var.mod_name_suffix}" }
}
# AWS route tables
resource "aws_route_table" "transit-VPC-route" {
    vpc_id      = "${aws_vpc.transit-VPC.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.transit-VPC-gw.id}"
    }
    tags      { Name = "transit-VPC-route-${var.mod_name_suffix}" }
    lifecycle { ignore_changes = ["route"] }
}
# AWS route associations public
resource "aws_route_table_association" "transit-VPC-ra" {
    subnet_id      = "${aws_subnet.transit-VPC-public-subnet.id}"
    route_table_id = "${aws_route_table.transit-VPC-route.id}"
    depends_on     = ["aws_subnet.transit-VPC-public-subnet","aws_route_table.transit-VPC-route","aws_internet_gateway.transit-VPC-gw","aws_vpc.transit-VPC"]
}

resource "aviatrix_transit_vpc" "transit_gw" {
    cloud_type   = 1
    account_name = "${var.mod_account_name}"
    gw_name      = "${var.mod_name_suffix}"
    vpc_id       = "${aws_vpc.transit-VPC.id}"
    vpc_reg      = "${var.mod_region}"
    vpc_size     = "${var.mod_gw_size}"
    ha_gw_size   = "${var.mod_gw_size}"
    subnet       = "${aws_subnet.transit-VPC-public-subnet.cidr_block}"
    ha_subnet    = "${aws_subnet.transit-VPC-public-subnet.cidr_block}"
}

#resource "aviatrix_vgw_conn" "bgp_vgw_conn" {
#    vpc_id           = "${var.vpc_id}"
#    conn_name        = "${var.vgw_conn_name}"
#    gw_name          = "${var.name_suffix}"
#    bgp_vgw_id       = "${var.vgw_id}"
#    bgp_local_as_num = "${var.bgp_local_as}"
#    depends_on       =["aviatrix_transit_vpc.transit_gw"]
#}
