# AWS Spoke VPCs
data "aws_availability_zones" "available" {}

resource "aws_vpc" "test-VPC" {
  cidr_block = "${var.vpc_cidr_prefix}.0/24"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  tags {
      Name = "test-VPC-${var.name_suffix}"
  }
}

# AWS Public Subnets
resource "aws_subnet" "test-VPC-public" {
  vpc_id = "${aws_vpc.test-VPC.id}"
  cidr_block = "${var.vpc_cidr_prefix}.0/28"
  map_public_ip_on_launch = "true"
  availability_zone = "${element(data.aws_availability_zones.available.names, 0)}"
  tags {
      Name = "test-VPC-public-${var.name_suffix}"
  }
  timeouts {
  }
  depends_on = ["aws_vpc.test-VPC"]
}

# AWS Public Subnets for HA
resource "aws_subnet" "test-VPC-public-ha" {
  vpc_id = "${aws_vpc.test-VPC.id}"
  cidr_block = "${var.vpc_cidr_prefix}.16/28"
  map_public_ip_on_launch = "true"
  availability_zone = "${element(data.aws_availability_zones.available.names, 1)}"
  tags {
      Name = "test-VPC-public-ha-${var.name_suffix}"
  }
  timeouts {
  }
  depends_on = ["aws_vpc.test-VPC"]
}

# AWS Internet GW
resource "aws_internet_gateway" "test-VPC-gw" {
  vpc_id = "${aws_vpc.test-VPC.id}"

  tags {
      Name = "test-VPC-gw-${var.name_suffix}"
  }
  timeouts {
  }
  depends_on = ["aws_vpc.test-VPC"]
}

# AWS route tables
resource "aws_route_table" "test-VPC-route" {
  vpc_id = "${aws_vpc.test-VPC.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.test-VPC-gw.id}"
  }

  tags {
      Name = "test-VPC-route-${var.name_suffix}"
  }
  lifecycle {
      ignore_changes = ["route"]
  }
  depends_on = ["aws_vpc.test-VPC","aws_internet_gateway.test-VPC-gw"]
}

# AWS route associations public
resource "aws_route_table_association" "test-VPC-ra" {
  subnet_id = "${aws_subnet.test-VPC-public.id}"
  route_table_id = "${aws_route_table.test-VPC-route.id}"
  depends_on = ["aws_subnet.test-VPC-public","aws_route_table.test-VPC-route","aws_internet_gateway.test-VPC-gw","aws_vpc.test-VPC"]
}

# AWS route associations public HA
resource "aws_route_table_association" "test-VPC-ra-ha" {
  subnet_id = "${aws_subnet.test-VPC-public-ha.id}"
  route_table_id = "${aws_route_table.test-VPC-route.id}"
  depends_on = ["aws_subnet.test-VPC-public","aws_route_table.test-VPC-route","aws_internet_gateway.test-VPC-gw","aws_vpc.test-VPC"]
}

