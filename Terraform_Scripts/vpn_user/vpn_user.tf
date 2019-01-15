# Creates a VPN user in Aviatrix Controller

resource "aviatrix_vpn_user" "test_vpn_user" {
  vpc_id      = "${var.aws_vpc_id}"
  gw_name     = "${var.aviatrix_gateway_name}"
  user_name   = "${var.aviatrix_vpn_user_name}"
  user_email  = "${var.aviatrix_vpn_user_email}"
}
