resource aviatrix_firewall test_firewall {
  gw_name           = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  base_policy       = var.aviatrix_firewall_base_policy
  base_log_enabled  = var.aviatrix_firewall_packet_logging
  manage_firewall_policies = false
}

resource aviatrix_firewall_policy test_firewall_p1 {
  gw_name = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  src_ip      = var.aviatrix_firewall_policy_source_ip[0]
  dst_ip      = var.aviatrix_firewall_policy_destination_ip[0]
  protocol    = var.aviatrix_firewall_policy_protocol[0]
  port        = var.aviatrix_firewall_policy_port[0]
  action      = var.aviatrix_firewall_policy_action[0]
  log_enabled = var.aviatrix_firewall_policy_log_enable[0]
}
resource aviatrix_firewall_policy test_firewall_p2 {
  gw_name = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  src_ip      = var.aviatrix_firewall_policy_source_ip[1]
  dst_ip      = var.aviatrix_firewall_policy_destination_ip[1]
  protocol    = var.aviatrix_firewall_policy_protocol[1]
  port        = var.aviatrix_firewall_policy_port[1]
  action      = var.aviatrix_firewall_policy_action[1]
  log_enabled = var.aviatrix_firewall_policy_log_enable[1]
}
resource aviatrix_firewall_policy test_firewall_p3 {
  gw_name = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  src_ip      = var.aviatrix_firewall_policy_source_ip[2]
  dst_ip      = var.aviatrix_firewall_policy_destination_ip[2]
  protocol    = var.aviatrix_firewall_policy_protocol[2]
  port        = var.aviatrix_firewall_policy_port[2]
  action      = var.aviatrix_firewall_policy_action[0]
  log_enabled = var.aviatrix_firewall_policy_log_enable[1]
}
resource aviatrix_firewall_policy test_firewall_p4 {
  gw_name = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  src_ip      = var.aviatrix_firewall_policy_source_ip[3]
  dst_ip      = var.aviatrix_firewall_policy_destination_ip[3]
  protocol    = var.aviatrix_firewall_policy_protocol[3]
  port        = var.aviatrix_firewall_policy_port[3]
  action      = var.aviatrix_firewall_policy_action[1]
  log_enabled = var.aviatrix_firewall_policy_log_enable[1]
}
resource aviatrix_firewall_policy test_firewall_p5 {
  gw_name = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  src_ip      = var.aviatrix_firewall_policy_source_ip[4]
  dst_ip      = var.aviatrix_firewall_policy_destination_ip[4]
  protocol    = var.aviatrix_firewall_policy_protocol[4]
  port        = var.aviatrix_firewall_policy_port[4]
  action      = var.aviatrix_firewall_policy_action[1]
  log_enabled = var.aviatrix_firewall_policy_log_enable[1]
}
resource aviatrix_firewall_policy test_firewall_p6 {
  gw_name = aviatrix_gateway.firewall_gateway["firewall-gw1"].gw_name
  src_ip      = var.aviatrix_firewall_policy_source_ip[5]
  dst_ip      = var.aviatrix_firewall_policy_destination_ip[5]
  protocol    = var.aviatrix_firewall_policy_protocol[5]
  port        = var.aviatrix_firewall_policy_port[5] # as of 6.2 port for protocol "all" must be blank
  action      = var.aviatrix_firewall_policy_action[1]
  log_enabled = var.aviatrix_firewall_policy_log_enable[1]
}

## Use to test ICMP and port case
resource aviatrix_firewall test_firewall_icmp {
  gw_name           = aviatrix_gateway.firewall_gateway["firewall-gw2"].gw_name
  base_policy       = var.aviatrix_firewall_base_policy
  base_log_enabled  = var.aviatrix_firewall_packet_logging

  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[6]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[6]
    protocol    = var.aviatrix_firewall_policy_protocol[6]
    port        = var.aviatrix_firewall_policy_port[6]
    action      = var.aviatrix_firewall_policy_action[0]
    log_enabled = var.aviatrix_firewall_policy_log_enable[0]
    description = var.aviatrix_firewall_policy_description
  }
  policy {
    src_ip      = var.aviatrix_firewall_policy_source_ip[7]
    dst_ip      = var.aviatrix_firewall_policy_destination_ip[7]
    protocol    = var.aviatrix_firewall_policy_protocol[7]
    port        = var.aviatrix_firewall_policy_port[7]
    action      = var.aviatrix_firewall_policy_action[2]
    log_enabled = var.aviatrix_firewall_policy_log_enable[0]
    description = "force-dropping these fools"
  }
}

output test_firewall_id {
  value = aviatrix_firewall.test_firewall.id
}

output test_firewall_p1_id {
  value = aviatrix_firewall_policy.test_firewall_p1.id
}

output test_firewall_icmp_id {
  value = aviatrix_firewall.test_firewall_icmp.id
}

## Data source
data aviatrix_firewall d_test_firewall {
  gw_name = aviatrix_firewall.test_firewall.gw_name
}

data aviatrix_firewall d_test_firewall_icmp {
  gw_name = aviatrix_firewall.test_firewall_icmp.gw_name
}

output d_test_firewall_id {
  value = data.aviatrix_firewall.d_test_firewall.id
}

output d_test_firewall_icmp_id {
  value = data.aviatrix_firewall.d_test_firewall_icmp.id
}
