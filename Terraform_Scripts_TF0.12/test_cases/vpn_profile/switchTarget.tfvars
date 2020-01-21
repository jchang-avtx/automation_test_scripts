# Test order 4: shifting all target addresses on policy; maintain swapped actions, ports, protocols

aviatrix_vpn_profile_user_list  = ["testdummy1",
                                   "testdummy2"]

aviatrix_vpn_profile_action     = ["deny", "allow"]
aviatrix_vpn_profile_protocol   = ["dccp",
                                   "all",
                                   "tcp",
                                   "udp",
                                   "icmp",
                                   "sctp",
                                   "rdp"]

aviatrix_vpn_profile_port       = ["5555",
                                   "0:65535",
                                   "5577",
                                   "5588",
                                   "0:65535",
                                   "5600",
                                   "5611"]

aviatrix_vpn_profile_target     = ["11.0.0.0/32",
                                   "12.0.0.0/32",
                                   "13.0.0.0/32",
                                   "14.0.0.0/32",
                                   "15.0.0.0/32",
                                   "16.0.0.0/32",
                                   "17.0.0.0/32"]
