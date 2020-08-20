## test case 1: change to icmp and test empty port as well as update description

aviatrix_firewall_policy_protocol         = ["tcp",
                                             "udp",
                                             "sctp",
                                             "rdp",
                                             "dccp",
                                             "all",
                                             "icmp",
                                             "tcp"]

aviatrix_firewall_policy_port             = [69,
                                             "0:65535",
                                             "25:420",
                                             420,
                                             65535,
                                             "",
                                             "",
                                             444]

aviatrix_firewall_policy_description      = "icmp firewall rule UPDATED"
