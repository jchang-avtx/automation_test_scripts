## test ICMP only issue
# ONLY USE THIS TFVARS IN CONJUNCTION WITH CASE 2 IN FIREWALL.TF
# There are various test cases testing ICMP protocol in isolation
# Please see Mantis: id=8063

## Make sure the controller credentials are filled
aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

aviatrix_gateway_name             = "firewall_gw_name"
aviatrix_firewall_base_policy     = "allow-all"
aviatrix_firewall_packet_logging  = "on"

## Case 1. With a port number
# Expected result: * "Port Range" must be blank/empty
aviatrix_firewall_policy_protocol         = ["icmp"]
aviatrix_firewall_policy_source_ip        = ["10.10.10.10/32"]
aviatrix_firewall_policy_log_enable       = ["on", "off"] # choose on or off in firewall.tf
aviatrix_firewall_policy_destination_ip   = ["11.11.11.11/32"]
aviatrix_firewall_policy_action           = ["allow", "deny"] # choose allow or deny in firewall.tf
aviatrix_firewall_policy_port             = ["69"]
