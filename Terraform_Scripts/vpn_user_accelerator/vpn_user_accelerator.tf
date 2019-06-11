## Note: dependent on creating a vpn-gateway and elb OR an existing ELB

resource "aviatrix_vpn_user_accelerator" "test_vpn_user_accel" {
  elb_name = "test-elb-name"
}
