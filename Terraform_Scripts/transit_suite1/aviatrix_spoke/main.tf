# AWS Spoke VPCs
data "aws_availability_zones" "available" {}

resource "aviatrix_spoke_vpc" "spoke0" {
  cloud_type   = 1
  account_name = "${var.account_name}"
  gw_name      = "${var.name_suffix}0"
  vpc_reg      = "${var.spoke_region}"
  vpc_size     = "${var.spoke_gw_size}"
  vpc_id       = "${var.spoke0_vpc_id}"
  subnet       = "${var.spoke0_subnet}"
  ha_subnet    = "${var.spoke0_subnet}"
  transit_gw   = "${var.transit_gateway}"
}
#resource "aviatrix_spoke_vpc" "spoke1" {
#  cloud_type   = 1
#  account_name = "${var.account_name}"
#  gw_name      = "${var.name_suffix}1"
#  vpc_reg      = "${var.spoke_region}"
#  vpc_size     = "${var.spoke_gw_size}"
#  vpc_id       = "${var.spoke1_vpc_id}"
#  subnet       = "${var.spoke1_subnet}"
#  ha_subnet    = "${var.spoke1_subnet}"
#  transit_gw   = "${var.transit_gateway}"
#}
#resource "aviatrix_spoke_vpc" "spoke2" {
#  cloud_type   = 1
#  account_name = "${var.account_name}"
#  gw_name      = "${var.name_suffix}2"
#  vpc_reg      = "${var.spoke_region}"
#  vpc_size     = "${var.spoke_gw_size}"
#  vpc_id       = "${var.spoke2_vpc_id}"
#  subnet       = "${var.spoke2_subnet}"
#  ha_subnet    = "${var.spoke2_subnet}"
#  transit_gw   = "${var.transit_gateway}"
#}
#
## Create encrypteed peering between shared to spoke gateway
resource "aviatrix_tunnel" "shared-to-spoke0"{
  vpc_name1        = "${var.shared_gateway}"
  vpc_name2        = "${var.name_suffix}0"
  cluster          = "no"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  enable_ha        = "yes"
}
#resource "aviatrix_tunnel" "shared-to-spoke1"{
#  vpc_name1        = "${var.shared_gateway}"
#  vpc_name2        = "${var.name_suffix}1"
#  cluster          = "no"
#  over_aws_peering = "no"
#  peering_hastatus = "yes"
#  enable_ha        = "yes"
#}
#resource "aviatrix_tunnel" "shared-to-spoke2"{
#  vpc_name1        = "${var.shared_gateway}"
#  vpc_name2        = "${var.name_suffix}2"
#  cluster          = "no"
#  over_aws_peering = "no"
#  peering_hastatus = "yes"
#  enable_ha        = "yes"
#}
