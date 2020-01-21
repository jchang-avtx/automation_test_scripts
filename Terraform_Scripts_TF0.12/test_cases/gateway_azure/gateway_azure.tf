## Create Azure Gateway

resource "random_integer" "vnet1_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "arm_gw_vnet_1" {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, random_integer.vnet1_cidr_int[2].result, "0/24"])
  cloud_type            = 8
  name                  = "arm-gw-vnet-1"
  region                = "Central US"
}

resource "aviatrix_gateway" "azure_gw" {
  cloud_type      = 8
  account_name    = "AzureAccess"
  gw_name         = "azure-gw"
  vpc_id          = aviatrix_vpc.arm_gw_vnet_1.vpc_id
  vpc_reg         = aviatrix_vpc.arm_gw_vnet_1.region
  gw_size         = "Standard_B1s"
  subnet          = aviatrix_vpc.arm_gw_vnet_1.subnets.0.cidr

  enable_snat     = true # do not enable if using peering_ha
  single_az_ha    = true

  vpn_access      = true
  vpn_cidr        = "192.168.43.0/24"
  enable_elb      = true
  elb_name        = "azureelb"
  enable_vpn_nat  = var.aviatrix_vpn_nat
  max_vpn_conn    = 100
}

output "azure_gw_id" {
  value = aviatrix_gateway.azure_gw.id
}
