## Note: dependent on creating a vpn-gateway and elb OR an existing ELB

resource "aviatrix_gateway" "vpn_gw_for_elb" {
  cloud_type = 1
  account_name = "PrimaryAccessAccount"
  gw_name = "vpnGWforELB"
  vpc_id = "vpc-abc123"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  vpc_net = "10.0.0.0/24"

  enable_nat = "yes"
  # single_az_ha = "enabled"

  vpn_access = "yes"
  vpn_cidr = "192.168.43.0/24"
  enable_elb = "yes"
  elb_name = "elb-for-vpn-user-accelerator"
  # saml_enabled = "yes"
}

resource "aviatrix_vpn_user_accelerator" "test_vpn_user_accel" {
  elb_name = "test-elb-name"
  depends_on = ["aviatrix_gateway.vpn_gw_for_elb"]
}
