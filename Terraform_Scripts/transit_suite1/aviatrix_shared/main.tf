resource "aviatrix_spoke_vpc" "test_spoke" {
    account_name = "${var.account_name}"
    cloud_type = 1
    gw_name = "${var.name_suffix}"
    vpc_id = "vpc-95ca2efd"
    vpc_reg = "${var.region}"
    vpc_size = "${var.gw_size}"
    subnet    = "10.224.0.0/24"
    ha_subnet = "10.224.0.0/24"
    transit_gw = "${var.transit_gw}"
}

