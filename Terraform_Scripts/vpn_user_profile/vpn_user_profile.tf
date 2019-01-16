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
      },
      {
        action    = "${var.aviatrix_vpn_profile_action[0]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[2]}"
        port      = "${var.aviatrix_vpn_profile_port[2]}"
        target    = "${var.aviatrix_vpn_profile_target[2]}"
      },
      {
        action    = "${var.aviatrix_vpn_profile_action[1]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[3]}"
        port      = "${var.aviatrix_vpn_profile_port[3]}"
        target    = "${var.aviatrix_vpn_profile_target[3]}"
      },
      {
        action    = "${var.aviatrix_vpn_profile_action[0]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[4]}"
        port      = "${var.aviatrix_vpn_profile_port[4]}"
        target    = "${var.aviatrix_vpn_profile_target[4]}"
      },
      {
        action    = "${var.aviatrix_vpn_profile_action[1]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[5]}"
        port      = "${var.aviatrix_vpn_profile_port[5]}"
        target    = "${var.aviatrix_vpn_profile_target[5]}"
      },
      {
        action    = "${var.aviatrix_vpn_profile_action[0]}"
        proto     = "${var.aviatrix_vpn_profile_protocol[6]}"
        port      = "${var.aviatrix_vpn_profile_port[6]}"
        target    = "${var.aviatrix_vpn_profile_target[6]}"
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
