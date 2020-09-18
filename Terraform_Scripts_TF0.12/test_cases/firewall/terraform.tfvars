## initial creation

aviatrix_firewall_base_policy     = "allow-all"
aviatrix_firewall_packet_logging  = true

aviatrix_firewall_policy_protocol         = ["tcp",
                                             "udp",
                                             "sctp",
                                             "rdp",
                                             "dccp",
                                             "all",
                                             "tcp",
                                             "tcp"]

aviatrix_firewall_policy_source_ip        = ["10.10.10.10/32",
                                             "12.12.12.12/32",
                                             "14.14.14.14/32",
                                             "16.16.16.16/32",
                                             "18.18.18.18/32",
                                             "20.20.20.20/32",
                                             "22.22.22.22/32",
                                             "24.24.24.24/32"]

aviatrix_firewall_policy_log_enable       = [true, false]

aviatrix_firewall_policy_destination_ip   = ["11.11.11.11/32",
                                             "13.13.13.13/32",
                                             "15.15.15.15/32",
                                             "17.17.17.17/32",
                                             "19.19.19.19/32",
                                             "21.21.21.21/32",
                                             "23.23.23.23/32",
                                             "25.25.25.25/32"]

aviatrix_firewall_policy_action           = ["allow", "deny", "force-drop"]

aviatrix_firewall_policy_port             = ["69",
                                             "0:65535",
                                             "25:420",
                                             "420",
                                             "65535",
                                             "0:65535",
                                             "0:100",
                                             "443"]

aviatrix_firewall_policy_description      = "icmp firewall rule #1"
