aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

aviatrix_gateway_name             = "FQDN-NAT-enabled"
aviatrix_firewall_base_policy     = "allow"
aviatrix_firewall_packet_logging  = "on"

aviatrix_firewall_policy_protocol         = ["tcp", "tcp", "udp", "icmp", "sctp", "rdp", "dccp", "icmp"]
aviatrix_firewall_policy_source_ip        = ["10.15.0.224/32", "10.10.10.10/32", "10.10.10.10/32", "10.10.10.10/32", "10.10.10.10/32", "10.10.10.10/32", "10.10.10.10/32", "10.10.10.10/32"]
aviatrix_firewall_policy_log_enable       = ["on", "off"] # can be referred to with [0] for on, [1] for off in firewall.tf
aviatrix_firewall_policy_destination_ip   = ["10.12.0.172/32", "10.12.1.172/32", "10.12.1.172/32", "10.12.1.172/32", "10.12.1.172/32", "10.12.1.172/32", "10.12.1.172/32", "10.12.1.172/32"]
aviatrix_firewall_policy_action           = ["allow", "deny"] # can be referred to with [0] for allow, [1] as deny in firewall.tf
aviatrix_firewall_policy_port             = ["443", "500", "4000", "500", "65535", "500", "65534", "1"]
