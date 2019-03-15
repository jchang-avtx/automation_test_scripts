## initial creation

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

aviatrix_gateway_name             = "firewall_gw_name"
aviatrix_firewall_base_policy     = "allow-all"
aviatrix_firewall_packet_logging  = "on"

aviatrix_firewall_policy_protocol         = ["tcp", "udp", "sctp", "rdp", "dccp", "all"]
aviatrix_firewall_policy_source_ip        = ["10.10.10.10/32", "12.12.12.12/32", "14.14.14.14/32", "16.16.16.16/32", "18.18.18.18/32", "20.20.20.20/32"]
aviatrix_firewall_policy_log_enable       = ["on", "off"] # Use 0 or 1 for enabling packet logging
aviatrix_firewall_policy_destination_ip   = ["11.11.11.11/32", "13.13.13.13/32", "15.15.15.15/32", "17.17.17.17/32", "19.19.19.19/32", "21.21.21.21/32"]
aviatrix_firewall_policy_action           = ["allow", "deny"] # Use 0 or 1 for allow or deny policy action
aviatrix_firewall_policy_port             = ["69", "0:65535", "25:420", "420", "65535", "0:65535"]
