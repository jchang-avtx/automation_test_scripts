## Create OnPrem VPC
## -----------------------------------
# Internet VPC
resource "aws_vpc" "VPC" {
    cidr_block = "${var.vpc_cidr_block}"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "VPC-${var.region}"
    }
}
# Subnets
resource "aws_subnet" "VPC-public" {
    vpc_id = "${aws_vpc.VPC.id}"
    cidr_block = "${var.vpc_cidr_block}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "VPC-public-${var.region}"
    }
}
# Internet GW
resource "aws_internet_gateway" "VPC-gw" {
    vpc_id = "${aws_vpc.VPC.id}"
    tags {
        Name = "VPC-gw-${var.region}"
    }
}
# route tables
resource "aws_route_table" "VPC-route" {
    vpc_id = "${aws_vpc.VPC.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.VPC-gw.id}"
    }
    tags {
        Name = "VPC-route-${var.region}"
    }
}
# route associations public
resource "aws_route_table_association" "VPC-ra" {
    subnet_id = "${aws_subnet.VPC-public.id}"
    route_table_id = "${aws_route_table.VPC-route.id}"
    depends_on = ["aws_subnet.VPC-public","aws_route_table.VPC-route","aws_internet_gateway.VPC-gw","aws_vpc.VPC"]
}
## END -------------------------------

