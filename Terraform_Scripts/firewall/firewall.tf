resource "aviatrix_firewall" "test_firewall" {
  gw_name = "${var.aviatrix_gateway_name}"
  base_allow_deny = "${var.aviatrix_firewall_base_policy}"
  base_log_enable = "${var.aviatrix_firewall_packet_logging}"
  policy = [
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[0]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[0]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[0]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[0]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[0]}"
      port = "${var.aviatrix_firewall_policy_port[0]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[1]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[1]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[1]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[1]}"
      port = "${var.aviatrix_firewall_policy_port[1]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[2]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[2]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[2]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[0]}"
      port = "${var.aviatrix_firewall_policy_port[2]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[3]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[3]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[3]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[1]}"
      port = "${var.aviatrix_firewall_policy_port[3]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[4]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[4]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[4]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[1]}"
      port = "${var.aviatrix_firewall_policy_port[4]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[5]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[5]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[5]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[1]}"
      port = "${var.aviatrix_firewall_policy_port[5]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[6]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[6]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[6]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[1]}"
      port = "${var.aviatrix_firewall_policy_port[6]}"
    },
    {
      protocol = "${var.aviatrix_firewall_policy_protocol[7]}"
      src_ip = "${var.aviatrix_firewall_policy_source_ip[7]}"
      log_enable = "${var.aviatrix_firewall_policy_log_enable[1]}"
      dst_ip = "${var.aviatrix_firewall_policy_destination_ip[7]}"
      allow_deny = "${var.aviatrix_firewall_policy_action[1]}"
      port = "${var.aviatrix_firewall_policy_port[7]}"
    }
  ]
}

# previous hard-coded version
# resource "aviatrix_firewall" "test_firewall" {
#   gw_name = "FQDN-NAT-enabled"
#   base_allow_deny = "allow"
#   base_log_enable = "on"
#   policy = [
#             {
#               protocol = "tcp"
#               src_ip = "10.15.0.224/32"
#               log_enable = "on"
#               dst_ip = "10.12.0.172/32"
#               allow_deny = "allow"
#               port = "443"
#             },
#             {
#               protocol = "tcp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "deny"
#               port = "500"
#             },
#             {
#               protocol = "udp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "allow"
#               port = "4000"
#             },
#             {
#               protocol = "icmp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "deny"
#               port = "500"
#             },
#             {
#               protocol = "sctp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "deny"
#               port = "65535"
#             },
#             {
#               protocol = "rdp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "deny"
#               port = "500"
#             },
#             {
#               protocol = "dccp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "deny"
#               port = "65534"
#             },
#             {
#               protocol = "icmp"
#               src_ip = "10.10.10.10/32"
#               log_enable = "off"
#               dst_ip = "10.12.1.172/32"
#               allow_deny = "deny"
#               port = "1"
#             }
#           ]
# }
