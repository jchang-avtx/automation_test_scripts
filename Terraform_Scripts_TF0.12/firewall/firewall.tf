resource "aviatrix_gateway" "test_gateway1" {
  cloud_type    = 1
  account_name  = "AnthonyPrimaryAccess"
  gw_name       = "firewallGW"
  vpc_id        = "vpc-ba3c12dd"
  vpc_reg       = "us-west-1"
  vpc_size      = "t2.micro"
  vpc_net       = "172.31.0.0/20"
}

resource "aviatrix_gateway" "test_gateway2" {
  cloud_type    = 1
  account_name  = "AnthonyPrimaryAccess"
  gw_name       = "firewallGW2"
  vpc_id        = "vpc-ba3c12dd"
  vpc_reg       = "us-west-1"
  vpc_size      = "t2.micro"
  vpc_net       = "172.31.16.0/20"
}

resource "aviatrix_firewall" "test_firewall" {
  gw_name           = aviatrix_gateway.test_gateway1.gw_name
  base_allow_deny   = var.aviatrix_firewall_base_policy
  base_log_enable   = var.aviatrix_firewall_packet_logging

  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[0]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[0]
    protocol    = var.aviatrix_firewall_policy_protocol[0]
    port        = var.aviatrix_firewall_policy_port[0]
    allow_deny  = var.aviatrix_firewall_policy_action[0]
    log_enable  = var.aviatrix_firewall_policy_log_enable[0]
  }
  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[1]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[1]
    protocol    = var.aviatrix_firewall_policy_protocol[1]
    port        = var.aviatrix_firewall_policy_port[1]
    allow_deny  = var.aviatrix_firewall_policy_action[1]
    log_enable  = var.aviatrix_firewall_policy_log_enable[1]
  }
  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[2]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[2]
    protocol    = var.aviatrix_firewall_policy_protocol[2]
    port        = var.aviatrix_firewall_policy_port[2]
    allow_deny  = var.aviatrix_firewall_policy_action[0]
    log_enable  = var.aviatrix_firewall_policy_log_enable[1]
  }
  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[3]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[3]
    protocol    = var.aviatrix_firewall_policy_protocol[3]
    port        = var.aviatrix_firewall_policy_port[3]
    allow_deny  = var.aviatrix_firewall_policy_action[1]
    log_enable  = var.aviatrix_firewall_policy_log_enable[1]
  }
  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[4]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[4]
    protocol    = var.aviatrix_firewall_policy_protocol[4]
    port        = var.aviatrix_firewall_policy_port[4]
    allow_deny  = var.aviatrix_firewall_policy_action[1]
    log_enable  = var.aviatrix_firewall_policy_log_enable[1]
  }
  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[5]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[5]
    protocol    = var.aviatrix_firewall_policy_protocol[5]
    port        = var.aviatrix_firewall_policy_port[5]
    allow_deny  = var.aviatrix_firewall_policy_action[1]
    log_enable  = var.aviatrix_firewall_policy_log_enable[1]
  }
  depends_on = ["aviatrix_gateway.test_gateway1"]
}

## Use to test ICMP and port case
resource "aviatrix_firewall" "test_firewall_icmp" {
  gw_name           = aviatrix_gateway.test_gateway2.gw_name
  base_allow_deny   = var.aviatrix_firewall_base_policy
  base_log_enable   = var.aviatrix_firewall_packet_logging

  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[6]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[6]
    protocol    = var.aviatrix_firewall_policy_protocol[6]
    port        = var.aviatrix_firewall_policy_port[6]
    allow_deny  = var.aviatrix_firewall_policy_action[0]
    log_enable  = var.aviatrix_firewall_policy_log_enable[0]
  }
  depends_on = ["aviatrix_gateway.test_gateway2"]
}
