# Creates a VPN user in Aviatrix Controller

resource "aviatrix_vpn_user" "test_vpn_user1" {
  vpc_id      = "${var.aws_vpc_id}"
  gw_name     = "${var.aviatrix_gateway_name}"
  user_name   = "${var.aviatrix_vpn_user_name["user1"]}"
  user_email  = "${var.aviatrix_vpn_user_email["email1"]}"
}

resource "aviatrix_vpn_user" "test_vpn_user2" {
  vpc_id      = "${var.aws_vpc_id}"
  gw_name     = "${var.aviatrix_gateway_name}"
  user_name   = "${var.aviatrix_vpn_user_name["user2"]}"
  user_email  = "${var.aviatrix_vpn_user_email["email2"]}"
}

resource "aviatrix_vpn_user" "test_vpn_user3" {
  vpc_id      = "${var.aws_vpc_id}"
  gw_name     = "${var.aviatrix_gateway_name}"
  user_name   = "${var.aviatrix_vpn_user_name["user3"]}"
  user_email  = "${var.aviatrix_vpn_user_email["email3"]}"
}

## test SAML
## comment out this section if you are not testing SAML along with in vars.tf and terraform.tfvars
resource "aviatrix_vpn_user" "test_vpn_user4" {
  vpc_id      = "${var.aws_vpc_id}"
  gw_name     = "${var.aviatrix_gateway_name}"
  user_name   = "${var.aviatrix_vpn_user_name["user4"]}"
  user_email  = "${var.aviatrix_vpn_user_email["email4"]}"
  saml_endpoint = "${var.aviatrix_vpn_user_saml[0]}"
}
