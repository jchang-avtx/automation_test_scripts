# AWS Spoke VPCs
data "aws_availability_zones" "available" {}

resource "aws_vpc" "spoke-VPC" {
    count = "${var.mod_ondemand_max_account}"
    cidr_block = "${var.mod_spoke_cidr_prefix}.${count.index}.0/24"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "spoke-VPC-${var.mod_name_suffix}-${count.index}"
    }
}
# AWS Public Subnets
resource "aws_subnet" "spoke-VPC-public" {
    count = "${var.mod_ondemand_max_account}"
    vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
    cidr_block = "${var.mod_spoke_cidr_prefix}.${count.index}.0/28"
    map_public_ip_on_launch = "true"
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
    tags {
        Name = "spoke-VPC-public-${var.mod_name_suffix}-${count.index}"
    }
    timeouts {
    }
}
# AWS Internet GW
resource "aws_internet_gateway" "spoke-VPC-gw" {
    count = "${var.mod_ondemand_max_account}"
    vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
    tags {
        Name = "spoke-VPC-gw-${var.mod_name_suffix}-${count.index}"
    }
    timeouts {
    }
}
# AWS route tables
resource "aws_route_table" "spoke-VPC-route" {
    count = "${var.mod_ondemand_max_account}"
    vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(aws_internet_gateway.spoke-VPC-gw.*.id,count.index)}"
    }
    tags {
        Name = "spoke-VPC-route-${var.mod_name_suffix}-${count.index}"
    }
    lifecycle {
        ignore_changes = ["route"]
    }
}
# AWS route associations public
resource "aws_route_table_association" "spoke-VPC-ra" {
    count          = "${var.mod_ondemand_max_account}"
    subnet_id      = "${element(aws_subnet.spoke-VPC-public.*.id,count.index)}"
    route_table_id = "${element(aws_route_table.spoke-VPC-route.*.id,count.index)}"
    depends_on     = ["aws_subnet.spoke-VPC-public","aws_route_table.spoke-VPC-route","aws_internet_gateway.spoke-VPC-gw","aws_vpc.spoke-VPC"]
}

resource "aviatrix_spoke_vpc" "ondemand0_spoke" {
  account_name = "${var.mod_ondemand_act_name[0]}"
  cloud_type   = "${var.mod_cloud_type}"
  gw_name      = "${var.mod_name_suffix}-${var.mod_ondemand_act_name[0]}"
  vpc_id       = "${element(aws_vpc.spoke-VPC.*.id,0)}"
  vpc_reg      = "${var.mod_spoke_region}"
  vpc_size     = "${var.mod_spoke_gw_size}"
  ha_gw_size   = "${var.mod_spoke_gw_size}"
  subnet       = "${element(aws_subnet.spoke-VPC-public.*.cidr_block,0)}"
  ha_subnet    = "${element(aws_subnet.spoke-VPC-public.*.cidr_block,0)}"
  transit_gw   = "${var.mod_transit_gateway}"
  depends_on   = ["aws_route_table_association.spoke-VPC-ra"]
}




