resource "aviatrix_transit_vpc" "test_transit_gw" {
    cloud_type = 1
    account_name = "${var.account_name}"
    gw_name= "${var.name_suffix}"
    vpc_id = "vpc-33c82c5b"
    vpc_reg = "${var.region}"
    vpc_size = "${var.gw_size}"
    subnet = "192.169.0.0/24"
    ha_subnet = "192.169.0.0/24"
}

# Create VGW connection with transit VPC.
resource "aviatrix_vgw_conn" "bgp_vgw_conn" {
    vpc_id = "vpc-33c82c5b"
    conn_name = "${var.vgw_connection_name}"
    gw_name = "${var.name_suffix}"
    bgp_vgw_id = "vgw-d9c14fe9"
    bgp_local_as_num = "${var.bgp_local_as}"
    depends_on =["aviatrix_transit_vpc.test_transit_gw"]
}
