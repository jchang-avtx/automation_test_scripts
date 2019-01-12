# Create a VPN user profile in Avx Controller

resource "aviatrix_vpn_profile" "terr_profile" {
  name            = "${var.aviatrix_vpn_profile_name}"
  base_rule       = "${var.aviatrix_vpn_profile_base_rule}"
  users           = "${var.aviatrix_vpn_profile_user_list}"
  policy = [
      {
        action    = "${var.aviatrix_vpn_profile_action[0]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[0]}"
        port      = "${var.aviatrix_vpn_profile_port[0]}"
        target    = "${var.aviatrix_vpn_profile_target[0]}"
      },
      {
        action    = "${var.aviatrix_vpn_profile_action[1]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[1]}"
        port      = "${var.aviatrix_vpn_profile_port[1]}"
        target    = "${var.aviatrix_vpn_profile_target[1]}"
      }
  ]
}

## previous hardcoded version
# resource "aviatrix_vpn_profile" "terr_profile" {
#   name            = "profile"
#   base_rule       = "allow_all"
#   users           = []
#   policy = [
#       {
#         action    = "allow"
#         proto     = "tcp"
#         port      = "5544"
#         target    = "10.0.0.0/32"
#       },
#       {
#         action    = "allow"
#         proto     = "tcp"
#         port      = "5244"
#         target    = "11.0.0.0/32"
#       }
#   ]
# }
