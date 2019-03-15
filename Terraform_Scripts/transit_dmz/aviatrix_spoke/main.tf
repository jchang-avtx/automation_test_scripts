resource "aviatrix_spoke_vpc" "spoke0" {
  cloud_type   = 1
  account_name = "${var.account_name}"
  gw_name      = "${var.name_suffix}0"
  vpc_reg      = "${var.spoke_region}"
  vpc_size     = "${var.spoke_gw_size}"
  ha_gw_size   = "${var.spoke_gw_size}"
  vpc_id       = "${var.spoke0_vpc_id}"
  subnet       = "${var.spoke0_subnet}"
  ha_subnet    = "${var.spoke0_subnet}"
  transit_gw   = "${var.transit_gateway}"
}

