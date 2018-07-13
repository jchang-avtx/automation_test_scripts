resource "aviatrix_transit_vpc" "transit_gw" {
    cloud_type = 1
    account_name = "${var.account_name}"
    gw_name= "${var.name_suffix}"
    vpc_id = "${var.vpc_id}"
    vpc_reg = "${var.region}"
    vpc_size = "${var.gw_size}"
    subnet = "${var.subnet}"
    ha_subnet = "${var.subnet}"
}

resource "aviatrix_vgw_conn" "bgp_vgw_conn" {
    vpc_id = "${var.vpc_id}"
    conn_name = "${var.vgw_conn_name}"
    gw_name = "${var.name_suffix}"
    bgp_vgw_id = "${var.vgw_id}"
    bgp_local_as_num = "${var.bgp_local_as}"
    depends_on =["aviatrix_transit_vpc.transit_gw"]
}
