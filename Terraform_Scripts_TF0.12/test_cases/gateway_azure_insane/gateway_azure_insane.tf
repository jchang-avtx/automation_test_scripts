# create an Azure gateway (insane mode enabled)

resource "aviatrix_gateway" "insane_azure_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "insaneAzureGW"
  vpc_id              = "AzureVNet:rg-av-AzureVNet-315693"
  vpc_reg             = "Central US"

  insane_mode         = true
  subnet              = "10.4.32.64/26"
  gw_size             = "Standard_D3_v2" # insane mode support D3+

  peering_ha_subnet   = "10.4.32.128/26"
  peering_ha_gw_size  = "Standard_D3_v2"


}

output "insane_azure_gw_id" {
  value = aviatrix_gateway.insane_azure_gw.id
}
