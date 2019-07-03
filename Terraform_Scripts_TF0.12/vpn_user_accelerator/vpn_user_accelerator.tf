resource "aviatrix_gateway" "vpn_gw_for_elb" {
  cloud_type      = 1
  account_name    = "AnthonyPrimaryAccess"
  gw_name         = "vpnGWforELB"
  vpc_id          = "vpc-0086065966b807866"
  vpc_net         = "10.0.2.0/24"
  vpc_reg         = "us-east-1"
  vpc_size        = "t2.micro"

  vpn_access      = "yes"
  vpn_cidr        = "192.168.43.0/24"
  enable_elb      = "yes"
  elb_name        = "elb-for-vpn-user-accel"
  max_vpn_conn    = 100
}


resource "aviatrix_vpn_user_accelerator" "test_vpn_user_accel" {
  elb_name        = aviatrix_gateway.vpn_gw_for_elb.elb_name

  depends_on      = ["aviatrix_gateway.vpn_gw_for_elb"]
}
