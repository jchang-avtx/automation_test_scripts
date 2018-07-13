# AWS Spoke VPCs
data "aws_availability_zones" "available" {}

resource "aviatrix_spoke_vpc" "spoke0" {
  cloud_type       = 1
  account_name     = "${var.account_name}"
  gw_name          = "${var.name_suffix}"
  vpc_id           = "${var.vpc_id}"
  vpc_reg          = "${var.spoke_region}"
  vpc_size         = "${var.spoke_gw_size}"
  subnet           = "${var.subnet}"
  ha_subnet        = "${var.subnet}"
  transit_gw       = "${var.transit_gateway}"
}
# Create encrypteed peering between shared to spoke gateway
resource "aviatrix_tunnel" "shared-to-spoke0"{
  vpc_name1        = "${var.shared_gateway}"
  vpc_name2        = "${var.name_suffix}"
  cluster          = "no"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  enable_ha        = "yes"
}
