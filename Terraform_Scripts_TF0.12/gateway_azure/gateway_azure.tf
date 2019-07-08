## Create Azure Gateway

resource "aviatrix_gateway" "azure_gw" {
  cloud_type      = 8
  account_name    = "AzureAccess"
  gw_name         = "azureGW"
  vpc_id          = "TransitVNet:TransitRG"
  vpc_reg         = "Central US"
  vpc_size        = "Standard_B1s"
  vpc_net         = "10.2.0.0/24"

  enable_nat      = "yes" # do not enable if using peering_ha
  single_az_ha    = "enabled"

  vpn_access      = "yes"
  vpn_cidr        = "192.168.43.0/24"
  enable_elb      = "yes"
  elb_name        = "azureelb"
  max_vpn_conn    = 100
}
