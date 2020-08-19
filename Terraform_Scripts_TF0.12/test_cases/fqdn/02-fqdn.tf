resource aviatrix_fqdn fqdn_tag_1 {
  fqdn_tag      = "fqdn-tag-1"
  fqdn_enabled  = var.aviatrix_fqdn_status
  fqdn_mode     = var.aviatrix_fqdn_mode

  gw_filter_tag_list {
    gw_name         = var.aviatrix_fqdn_gateway
    source_ip_list  = var.aviatrix_fqdn_source_ip_list
  }

  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[0]
    proto  = var.aviatrix_fqdn_protocol[0]
    port   = var.aviatrix_fqdn_port[0]
    action = var.aviatrix_fqdn_action[0]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[1]
    proto  = var.aviatrix_fqdn_protocol[1]
    port   = var.aviatrix_fqdn_port[1]
    action = var.aviatrix_fqdn_action[1]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[2]
    proto  = var.aviatrix_fqdn_protocol[2]
    port   = var.aviatrix_fqdn_port[2]
    action = var.aviatrix_fqdn_action[2]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[3]
    proto  = var.aviatrix_fqdn_protocol[3]
    port   = var.aviatrix_fqdn_port[3]
    action = var.aviatrix_fqdn_action[3]
  }

  depends_on = [aviatrix_gateway.fqdn_gw_1, aviatrix_gateway.fqdn_gw_2]
}

###############################################################################
resource aviatrix_fqdn fqdn_tag_2 {
  fqdn_tag      = "fqdn-tag-2"
  fqdn_enabled  = true
  fqdn_mode     = "black"
  manage_domain_names = false

  gw_filter_tag_list {
    gw_name         = aviatrix_gateway.fqdn_gw_3.gw_name
  }
}

resource aviatrix_fqdn_tag_rule fqdn_tag_2_r1 {
  fqdn_tag_name = aviatrix_fqdn.fqdn_tag_2.id
  fqdn = "digg.com"
  protocol = "tcp"
  port = 443
}

###############################################################################
resource aviatrix_fqdn_pass_through fqdn_ignore {
  gw_name = var.aviatrix_fqdn_gateway == "fqdn-gw-1" ? aviatrix_gateway.fqdn_gw_1.gw_name : aviatrix_gateway.fqdn_gw_2.gw_name
  pass_through_cidrs = var.pass_thru_list

  depends_on = [aviatrix_fqdn.fqdn_tag_1]
}

###############################################################################
output fqdn_tag_1_id {
  value = aviatrix_fqdn.fqdn_tag_1.id
}

output fqdn_ignore_id {
  value = aviatrix_fqdn_pass_through.fqdn_ignore.id
}

output fqdn_tag_2_r1_id {
  value = aviatrix_fqdn_tag_rule.fqdn_tag_2_r1.id
}
