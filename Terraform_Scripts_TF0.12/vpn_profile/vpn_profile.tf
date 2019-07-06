# Create a VPN user profiles in Avx Controller

resource "aviatrix_vpn_profile" "test_profile1" {
  name            = "profile Name1"
  base_rule       = "deny_all"
  users           = var.aviatrix_vpn_profile_user_list

  policy {
    action    = var.aviatrix_vpn_profile_action[0]
    proto     = var.aviatrix_vpn_profile_protocol[0]
    port      = var.aviatrix_vpn_profile_port[0]
    target    = var.aviatrix_vpn_profile_target[0]
  }
  policy {
    action    = var.aviatrix_vpn_profile_action[1]
    proto     = var.aviatrix_vpn_profile_protocol[1]
    port      = var.aviatrix_vpn_profile_port[1]
    target    = var.aviatrix_vpn_profile_target[1]
  }
  policy {
    action    = var.aviatrix_vpn_profile_action[0]
    proto     = var.aviatrix_vpn_profile_protocol[2]
    port      = var.aviatrix_vpn_profile_port[2]
    target    = var.aviatrix_vpn_profile_target[2]
  }
  policy {
    action    = var.aviatrix_vpn_profile_action[1]
    proto     = var.aviatrix_vpn_profile_protocol[3]
    port      = var.aviatrix_vpn_profile_port[3]
    target    = var.aviatrix_vpn_profile_target[3]
  }
  policy {
    action    = var.aviatrix_vpn_profile_action[0]
    proto     = var.aviatrix_vpn_profile_protocol[4]
    port      = var.aviatrix_vpn_profile_port[4]
    target    = var.aviatrix_vpn_profile_target[4]
  }
  policy {
    action    = var.aviatrix_vpn_profile_action[1]
    proto     = var.aviatrix_vpn_profile_protocol[5]
    port      = var.aviatrix_vpn_profile_port[5]
    target    = var.aviatrix_vpn_profile_target[5]
  }
  policy {
    action    = var.aviatrix_vpn_profile_action[0]
    proto     = var.aviatrix_vpn_profile_protocol[6]
    port      = var.aviatrix_vpn_profile_port[6]
    target    = var.aviatrix_vpn_profile_target[6]
  }
}

resource "aviatrix_vpn_profile" "test_profile2" {
  name            = "profile Name2"
  base_rule       = "allow_all"
  users           = ["testdummy3, testdummy4"]

  policy {
    action    = "deny"
    proto     = "tcp"
    port      = "443"
    target    = "10.0.0.0/32"
  }
  policy {
    action    = "allow"
    proto     = "udp"
    port      = "0:65535"
    target    = "10.0.0.1/32"
  }

}
