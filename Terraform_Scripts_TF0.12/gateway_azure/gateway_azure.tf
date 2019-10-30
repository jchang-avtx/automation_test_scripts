## Create Azure Gateway

resource "aviatrix_gateway" "azure_gw" {
  cloud_type      = 8
  account_name    = "AzureAccess"
  gw_name         = "azureGW"
  vpc_id          = "TransitVNet:TransitRG"
  vpc_reg         = "Central US"
  gw_size         = "Standard_B1s"
  subnet          = "10.2.0.0/24"

  enable_snat     = true # do not enable if using peering_ha
  single_az_ha    = true

  vpn_access      = true
  vpn_cidr        = "192.168.43.0/24"
  enable_elb      = true
  elb_name        = "azureelb"
  enable_vpn_nat  = var.aviatrix_vpn_nat
  max_vpn_conn    = 100
}
