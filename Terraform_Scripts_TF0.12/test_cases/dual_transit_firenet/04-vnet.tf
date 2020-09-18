# Azure
resource aviatrix_vpc azure_transit_firenet_vnet {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  region = "Central US"
  name = "azure-tf-vnet"
  cidr = "65.47.108.0/24"

  aviatrix_firenet_vpc = true
}

resource aviatrix_vpc azure_egress_vnet {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  region = "East US"
  name = "azure-egress-vnet"
  cidr = "92.23.125.0/24"

  aviatrix_firenet_vpc = true
}

resource aviatrix_vpc dual_firenet_spoke_vnet_1 {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  region = "East US 2"
  name = "dual-firenet-spoke-vnet-1"
  cidr = "57.44.55.0/16"
}

resource aviatrix_vpc dual_firenet_spoke_vnet_2 {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  region = "East US 2"
  name = "dual-firenet-spoke-vnet-2"
  cidr = "117.119.9.0/16"
}
