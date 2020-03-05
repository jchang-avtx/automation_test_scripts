## Create Aviatrix ARM Peering

resource "random_integer" "vnet1_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "random_integer" "vnet2_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "aviatrix_vpc" "arm_vnet_1" {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, random_integer.vnet1_cidr_int[2].result, "0/24"])
  cloud_type            = 8
  name                  = "armVNETpeer1"
  region                = "Central US"
}

resource "aviatrix_vpc" "arm_vnet_2" {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet2_cidr_int[0].result, random_integer.vnet2_cidr_int[1].result, random_integer.vnet2_cidr_int[2].result, "0/24"])
  cloud_type            = 8
  name                  = "armVNETpeer2"
  region                = "East US"
}

resource "aviatrix_arm_peer" "test_armpeer" {
  account_name1 = "AzureAccess"
  account_name2 = "AzureAccess"

  vnet_name_resource_group1  = aviatrix_vpc.arm_vnet_1.vpc_id
  vnet_name_resource_group2  = aviatrix_vpc.arm_vnet_2.vpc_id
  vnet_reg1                  = aviatrix_vpc.arm_vnet_1.region
  vnet_reg2      = aviatrix_vpc.arm_vnet_2.region
}

output "test_armpeer_id" {
  value = aviatrix_arm_peer.test_armpeer.id
}
