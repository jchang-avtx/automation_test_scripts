# Manage Aviatrix Controller Upgrade process

# Once this resource is created, VGW can be disconnected
# from transit GW by destroying this resource using command:
# terraform destroy --target aviatrix_vgw_conn.test_vgw_conn.

resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name = "${var.tgw_vgw_conn_name}"
  gw_name = "${var.aviatrix_gateway_name}"
  vpc_id = "${var.aws_vpc_id}"
  bgp_vgw_id = "${var.aws_vgw_id}"
  bgp_local_as_num = "${var.bgp_local_as}"
}
