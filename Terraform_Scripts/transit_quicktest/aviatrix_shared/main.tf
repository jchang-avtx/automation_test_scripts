resource "aviatrix_spoke_vpc" "test_spoke" {
    account_name = "${var.account_name}"
    cloud_type = 1
    gw_name = "${var.name_suffix}"
    vpc_id = "${var.vpc_id}"
    vpc_reg = "${var.region}"
    vpc_size = "${var.gw_size}"
    subnet    = "${var.subnet}"
    ha_subnet    = "${var.subnet}"
    transit_gw = "${var.transit_gateway}"
}

