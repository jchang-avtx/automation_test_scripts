resource aviatrix_device_virtual_wan_attachment csr_virtual_wan_att {
  count = var.azure_virtual_wan_att_status ? 1 : 0

  connection_name       = "csr-virtual-wan-att"
  device_name           = aviatrix_device_registration.csr_branch_router.name
  account_name          = "AzureAccess"
  resource_group        = "AzureWANRG"
  hub_name              = "avx-csr-azure-virtual-wan-hub-0" # 10.11.0.0/16
  device_bgp_asn        = 65001 # 65515 the ASN of the hub

  depends_on = [aviatrix_device_interface_config.csr_wan_discovery]
}
