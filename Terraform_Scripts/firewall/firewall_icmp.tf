# initial creation (icmp only)

# note: use 0 or 1 for log_enable for on or off respectively
# note: use 0 or 1 for allow_deny for allow or deny respectively
# comment out sections to test different cases (everything), (ICMP protocol) or ("ALL")

resource "aviatrix_gateway" "test_gateway1" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "firewall_gw_name"
  vpc_id = "vpc-abc123"
  vpc_reg = "us-west-1"
  vpc_size = "t2.micro"
  vpc_net = "10.0.0.0/24"
  tag_list = ["k1:v1", "k2:v2"]
}

##############################################
# Case 2. ICMP ONLY; run along with icmponly.tfvars
# Expected result: < depends on the variables passed in icmponly.tfvars >
# Please see Mantis: id=8063
##############################################
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
    }
  ]
  depends_on = ["aviatrix_gateway.test_gateway1"]
}
