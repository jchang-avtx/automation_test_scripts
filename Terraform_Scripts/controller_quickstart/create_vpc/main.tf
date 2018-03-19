# AWS Spoke VPCs
data "aws_availability_zones" "available" {}

resource "aws_vpc" "test-VPC" {
  count = "${var.vpc_count}"
  cidr_block = "${var.vpc_cidr_prefix}.${count.index}.0/24"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  tags {
      Name = "test-VPC-${var.name_suffix}-${count.index}"
  }
}

# AWS Public Subnets
resource "aws_subnet" "test-VPC-public" {
  count = "${var.vpc_count}"
  vpc_id = "${element(aws_vpc.test-VPC.*.id,count.index)}"
  cidr_block = "${var.vpc_cidr_prefix}.${count.index}.0/28"
  map_public_ip_on_launch = "true"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags {
      Name = "test-VPC-public-${var.name_suffix}-${count.index}"
  }
  timeouts {
  }
  depends_on = ["aws_vpc.test-VPC"]
}

# AWS Public Subnets for HA
resource "aws_subnet" "test-VPC-public-ha" {
  count = "${var.vpc_count}"
  vpc_id = "${element(aws_vpc.test-VPC.*.id,count.index)}"
  cidr_block = "${var.vpc_cidr_prefix}.${count.index}.16/28"
  map_public_ip_on_launch = "true"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index+1)}"
  tags {
      Name = "test-VPC-public-ha-${var.name_suffix}-${count.index}"
  }
  timeouts {
  }
  depends_on = ["aws_vpc.test-VPC"]
}

# AWS Internet GW
resource "aws_internet_gateway" "test-VPC-gw" {
  count = "${var.vpc_count}"
  vpc_id = "${element(aws_vpc.test-VPC.*.id,count.index)}"

  tags {
      Name = "test-VPC-gw-${var.name_suffix}-${count.index}"
  }
  timeouts {
  }
  depends_on = ["aws_vpc.test-VPC"]
}

# AWS route tables
resource "aws_route_table" "test-VPC-route" {
  count = "${var.vpc_count}"
  vpc_id = "${element(aws_vpc.test-VPC.*.id,count.index)}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${element(aws_internet_gateway.test-VPC-gw.*.id,count.index)}"
  }

  tags {
      Name = "test-VPC-route-${var.name_suffix}-${count.index}"
  }
  lifecycle {
      ignore_changes = ["route"]
  }
  depends_on = ["aws_vpc.test-VPC","aws_internet_gateway.test-VPC-gw"]
}

# AWS route associations public
resource "aws_route_table_association" "test-VPC-ra" {
  count = "${var.vpc_count}"
  subnet_id = "${element(aws_subnet.test-VPC-public.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.test-VPC-route.*.id,count.index)}"
  depends_on = ["aws_subnet.test-VPC-public","aws_route_table.test-VPC-route","aws_internet_gateway.test-VPC-gw","aws_vpc.test-VPC"]
}

# AWS route associations public HA
resource "aws_route_table_association" "test-VPC-ra-ha" {
  count = "${var.vpc_count}"
  subnet_id = "${element(aws_subnet.test-VPC-public-ha.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.test-VPC-route.*.id,count.index)}"
  depends_on = ["aws_subnet.test-VPC-public","aws_route_table.test-VPC-route","aws_internet_gateway.test-VPC-gw","aws_vpc.test-VPC"]
}

