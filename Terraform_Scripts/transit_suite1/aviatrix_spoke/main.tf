# AWS Spoke VPCs
data "aws_availability_zones" "available" {}

resource "aviatrix_spoke_vpc" "spoke0" {
  cloud_type = 1
  account_name = "${var.account_name}"
  gw_name = "${var.name_suffix}-0"
  vpc_id = "vpc-1ac92d72"
  vpc_reg = "${var.spoke_region}"
  vpc_size = "${var.spoke_gw_size}"
  subnet    = "10.1.0.0/24"
  ha_subnet = "10.1.0.0/24"
  transit_gw = "${var.transit_gateway_name}"
}
resource "aviatrix_spoke_vpc" "spoke1" {
  cloud_type = 1
  account_name = "${var.account_name}"
  gw_name = "${var.name_suffix}-1"
  vpc_id = "vpc-d1c82cb9"
  vpc_reg = "${var.spoke_region}"
  vpc_size = "${var.spoke_gw_size}"
  subnet    = "10.1.1.0/24"
  ha_subnet = "10.1.1.0/24"
  transit_gw = "${var.transit_gateway_name}"
}
resource "aviatrix_spoke_vpc" "spoke2" {
  cloud_type = 1
  account_name = "${var.account_name}"
  gw_name = "${var.name_suffix}-2"
  vpc_id = "vpc-43c92d2b"
  vpc_reg = "${var.spoke_region}"
  vpc_size = "${var.spoke_gw_size}"
  subnet    = "10.1.2.0/24"
  ha_subnet = "10.1.2.0/24"
  transit_gw = "${var.transit_gateway_name}"
}


# Create encrypteed peering between shared to spoke gateway
resource "aviatrix_tunnel" "shared-to-spoke0"{
  vpc_name1 = "canada-shared"
  vpc_name2 = "${var.name_suffix}-0"
  cluster   = "no"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  enable_ha        = "yes"
}
resource "aviatrix_tunnel" "shared-to-spoke1"{
  vpc_name1 = "canada-shared"
  vpc_name2 = "${var.name_suffix}-1"
  cluster   = "no"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  enable_ha        = "yes"
}
resource "aviatrix_tunnel" "shared-to-spoke2"{
  vpc_name1 = "canada-shared"
  vpc_name2 = "${var.name_suffix}-2"
  cluster   = "no"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  enable_ha        = "yes"
}
