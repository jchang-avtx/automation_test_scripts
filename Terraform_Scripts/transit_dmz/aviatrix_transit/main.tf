resource "aviatrix_transit_vpc" "transit_main_gateway" {
    cloud_type = 1
    account_name = "${var.account_name}"
    gw_name      = "${var.name_suffix}-main"
    vpc_id       = "${var.vpc_id}"
    vpc_reg      = "${var.region}"
    vpc_size     = "${var.gw_size}"
    ha_gw_size   = "${var.gw_size}"
    subnet       = "192.192.192.80/28"
    ha_subnet    = "192.192.192.112/28"
    connected_transit        = "yes"
    enable_hybrid_connection = true
}

resource "aviatrix_transit_vpc" "transit_companion_gateway" {
    cloud_type = 1
    account_name = "${var.account_name}"
    gw_name      = "${var.name_suffix}-companion"
    vpc_id       = "${var.vpc_id}"
    vpc_reg      = "${var.region}"
    vpc_size     = "${var.gw_size}"
    ha_gw_size   = "${var.gw_size}"
    subnet       = "192.192.192.80/28"
    ha_subnet    = "192.192.192.112/28"
    connected_transit        = "yes"
    enable_hybrid_connection = true
}


resource "aviatrix_vgw_conn" "bgp_vgw_conn" {
    vpc_id       = "${var.vpc_id}"
    conn_name    = "${var.vgw_conn_name}"
    gw_name      = "${var.name_suffix}-companion"
    bgp_vgw_id   = "${var.vgw_id}"
    bgp_local_as_num = "${var.bgp_local_as}"
    depends_on   =["aviatrix_transit_vpc.transit_companion_gateway"]
}

