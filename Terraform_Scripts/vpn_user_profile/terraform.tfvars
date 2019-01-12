aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

aviatrix_vpn_profile_name       = "profile"
aviatrix_vpn_profile_base_rule  = "allow_all"
aviatrix_vpn_profile_user_list  = ["user1"]

aviatrix_vpn_profile_action     = ["allow", "deny"]
aviatrix_vpn_profile_protocol   = ["tcp", "udp"]
aviatrix_vpn_profile_port       = ["5544", "5555"]
aviatrix_vpn_profile_target     = ["10.0.0.0/32", "11.0.0.0/32"]
