# depends on an pre-existing elb-vpn-user-accel ELB

resource "aviatrix_vpn_user_accelerator" "test_vpn_user_accel" {
  elb_name        = "elb-vpn-user-accel"

  # depends_on      = ["aviatrix_gateway.vpn_gw_for_elb"]
}

output "test_vpn_user_accel_id" {
  value = aviatrix_vpn_user_accelerator.test_vpn_user_accel.id
}
