resource "aviatrix_gateway" "vpn_gw_for_elb" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "vpnGWforELB"
  vpc_id          = "vpc-0086065966b807866"
  subnet          = "10.0.2.0/24"
  vpc_reg         = "us-east-1"
  gw_size         = "t2.micro"

  vpn_access      = true
  vpn_cidr        = "192.168.43.0/24"
  enable_elb      = true
  elb_name        = "elb-for-vpn-user-accel"
  max_vpn_conn    = 100
}


resource "aviatrix_vpn_user_accelerator" "test_vpn_user_accel" {
  elb_name        = aviatrix_gateway.vpn_gw_for_elb.elb_name

  depends_on      = ["aviatrix_gateway.vpn_gw_for_elb"]
}
