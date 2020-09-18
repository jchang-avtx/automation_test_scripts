resource time_sleep wait_2_min {
  create_duration = "2m"

  depends_on = [
    aws_instance.csr_instance_1
  ]
}

resource aviatrix_branch_router_registration csr_branch_router {
  name = "csr-branch-1"
  public_ip = aws_eip.csr_eip_1.public_ip
  username = "ec2-user"
  key_file = var.branch_router_key
  host_os = "ios"
  ssh_port = 22

  # optional info
  address_1 = "1234 Example St"
  address_2 = "567 Foobar Lane"
  city = "Somecity"
  state = "California"
  country = "US"
  zip_code = 12345
  description = "hello world"

  ## attachment - moved to separate resource
  ## HA support for CloudWAN removed in 6.1
  # wan_primary_interface = "GigabitEthernet1"
  # wan_primary_interface_public_ip = aws_eip.csr_eip_1.public_ip # CSR perspective = Private IP of the ENI
  # wan_backup_interface = "GigabitEthernet2"
  # wan_backup_interface_public_ip = aws_eip.csr_eip_2.public_ip

  lifecycle {
    ignore_changes = [key_file]
  }
  depends_on = [
    time_sleep.wait_2_min
  ]
}

# set up HA branch to allow WAN interface discovery (EDIT: removed support in 6.1)
resource aviatrix_branch_router_tag csr_branch_router_warn_tag {
  name = "csr-branch-router-warn-tag"
  branch_router_names = [aviatrix_branch_router_registration.csr_branch_router.name]
  # config = "interface GigabitEthernet2 \n no shut \n ip address dhcp"
  config = "logging buffered warnings"
}

resource time_sleep wait_2_min_tag_commit {
  create_duration = "2m"

  depends_on = [
    aviatrix_branch_router_tag.csr_branch_router_warn_tag
  ]
}

resource aviatrix_branch_router_interface_config csr_wan_discovery {
  branch_router_name = aviatrix_branch_router_registration.csr_branch_router.name
  wan_primary_interface = "GigabitEthernet1"
  wan_primary_interface_public_ip = aws_eip.csr_eip_1.public_ip # CSR perspective = Private IP of the ENI

  ## HA support for CloudWAN removed in 6.1
  # wan_backup_interface = "GigabitEthernet2"
  # wan_backup_interface_public_ip = aws_eip.csr_eip_2.public_ip

  depends_on = [
    time_sleep.wait_2_min_tag_commit
  ]
}

## attach branch to cloud
resource aviatrix_branch_router_transit_gateway_attachment csr_transit_att {
  count = var.avx_transit_att_status ? 1 : 0

  branch_name = aviatrix_branch_router_registration.csr_branch_router.name
  transit_gateway_name = aviatrix_transit_gateway.csr_transit_gw[0].gw_name
  connection_name = "csr-transit-conn"
  transit_gateway_bgp_asn = 65000
  branch_router_bgp_asn = 65001

  # algorithms
  phase1_authentication = "SHA-512"
  phase1_dh_groups = 1
  phase1_encryption = "AES-128-CBC"
  phase2_authentication = "HMAC-SHA-512"
  phase2_dh_groups = 1
  phase2_encryption = "AES-128-CBC"

  enable_global_accelerator = true
  # enable_branch_router_ha = false # no longer supported in 6.1

  # optional
  pre_shared_key = "abc123"
  local_tunnel_ip = "172.17.11.2/30"
  remote_tunnel_ip = "172.17.11.1/30"
  # backup_pre_shared_key = "abc123"
  # backup_local_tunnel_ip = "172.17.12.2/30"
  # backup_remote_tunnel_ip = "172.17.12.1/30"

  lifecycle {
    ignore_changes = [pre_shared_key]
  }

  depends_on = [aviatrix_branch_router_interface_config.csr_wan_discovery]
}

resource aviatrix_branch_router_aws_tgw_attachment csr_tgw_att {
  count = var.aws_tgw_att_status ? 1 : 0

  connection_name = "csr-tgw-conn"
  branch_name = aviatrix_branch_router_registration.csr_branch_router.name
  aws_tgw_name = aviatrix_aws_tgw.csr_aws_tgw[0].tgw_name
  branch_router_bgp_asn = 65001
  security_domain_name = "Default_Domain"

  depends_on = [aviatrix_branch_router_interface_config.csr_wan_discovery]
}
