# ARM FireNet Solution
# (13061) Add Terraform support for Transit FireNet
# (13096) Add Azure Spoke Native Peering

#################################################
# Infrastructure
#################################################
# Transit
resource "random_integer" "vnet1_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "arm_transit_firenet_vnet" {
  cloud_type            = 8
  account_name          = "AzureAccess"
  region                = "Central US"
  name                  = "arm-transit-firenet-vnet"
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, random_integer.vnet1_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
}
resource "aviatrix_transit_gateway" "arm_transit_firenet_gateway" {
  cloud_type    = 8
  account_name  = "AzureAccess"
  gw_name       = "arm-transit-firenet-gateway"
  vpc_id        = aviatrix_vpc.arm_transit_firenet_vnet.vpc_id
  vpc_reg       = aviatrix_vpc.arm_transit_firenet_vnet.region
  gw_size       = "Standard_B2ms"
  subnet        = aviatrix_vpc.arm_transit_firenet_vnet.subnets.1.cidr

  ha_gw_size    = "Standard_B2ms"
  ha_subnet     = aviatrix_vpc.arm_transit_firenet_vnet.subnets.3.cidr

  # enable_firenet            = true # cannot set this if setting transit firenet
  enable_transit_firenet    = true # pull (298)
  enable_hybrid_connection  = false # must be enabled if transit_firenet is ; not supported in Azure
  connected_transit         = true
  enable_active_mesh        = true # must be enabled
}

# Spoke 1
resource "random_integer" "vnet2_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "arm_transit_firenet_spoke_vnet" {
  cloud_type            = 8
  account_name          = "AzureAccess"
  region                = "East US"
  name                  = "arm-transit-firenet-spoke-vnet"
  cidr                  = join(".", [random_integer.vnet2_cidr_int[0].result, random_integer.vnet2_cidr_int[1].result, random_integer.vnet2_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}
# NOTE: ARM spoke gateway can be removed from workflow to use ARM Native Spoke Peering feature (13096)
# resource "aviatrix_spoke_gateway" "arm_transit_firenet_spoke_gateway" {
#   cloud_type    = 8
#   account_name  = "AzureAccess"
#   gw_name       = "arm-transit-firenet-spoke-gateway"
#   vpc_id        = aviatrix_vpc.arm_transit_firenet_spoke_vnet.vpc_id
#   vpc_reg       = aviatrix_vpc.arm_transit_firenet_spoke_vnet.region
#   gw_size       = "Standard_B2ms"
#   subnet        = aviatrix_vpc.arm_transit_firenet_spoke_vnet.subnets.0.cidr
#
#   ha_gw_size    = "Standard_B2ms"
#   ha_subnet     = aviatrix_vpc.arm_transit_firenet_spoke_vnet.subnets.2.cidr
#
#   enable_active_mesh  = true
#   transit_gw          = aviatrix_transit_gateway.arm_transit_firenet_gateway.gw_name
# }
resource "aviatrix_azure_spoke_native_peering" "arm_transit_firenet_spoke_native_peer" {
  spoke_account_name  = aviatrix_vpc.arm_transit_firenet_spoke_vnet.account_name
  spoke_region        = aviatrix_vpc.arm_transit_firenet_spoke_vnet.region
  spoke_vpc_id        = aviatrix_vpc.arm_transit_firenet_spoke_vnet.vpc_id
  transit_gateway_name  = aviatrix_transit_gateway.arm_transit_firenet_gateway.gw_name
  depends_on          = [aviatrix_firenet.arm_firenet]
}

#################################################
# FireNet
#################################################
resource "aviatrix_firewall_instance" "arm_transit_firenet_inst" {
  vpc_id                  = aviatrix_vpc.arm_transit_firenet_vnet.vpc_id
  firenet_gw_name         = aviatrix_transit_gateway.arm_transit_firenet_gateway.gw_name
  firewall_name           = "arm-transit-firenet-inst"
  firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version  = "9.1.0"
  firewall_size           = "Standard_D3_v2"
  egress_subnet           = aviatrix_vpc.arm_transit_firenet_vnet.subnets.0.cidr
  management_subnet       = aviatrix_vpc.arm_transit_firenet_vnet.subnets.2.cidr
  # key_name              = "randomKeyName.pem"
  # iam_role                = "bootstrap-VM-S3-role" # ensure that role is for EC2
  # bootstrap_bucket_name   = "bootstrap-bucket-firenet"
  username                = "arm-transit-firenet-user"
  password                = "ARM-transit-firenet-pa55"
}
resource "aviatrix_firenet" "arm_firenet" {
  vpc_id              = aviatrix_vpc.arm_transit_firenet_vnet.vpc_id
  inspection_enabled  = true # default true (reversed if FQDN use case)
  egress_enabled      = false # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.arm_transit_firenet_gateway.gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.arm_transit_firenet_inst.firewall_name
    instance_id           = aviatrix_firewall_instance.arm_transit_firenet_inst.instance_id
    lan_interface         = aviatrix_firewall_instance.arm_transit_firenet_inst.lan_interface
    management_interface  = aviatrix_firewall_instance.arm_transit_firenet_inst.management_interface
    egress_interface      = aviatrix_firewall_instance.arm_transit_firenet_inst.egress_interface
    attached              = true # updateable
  }
}

#################################################
# Transit FireNet
#################################################
# resource "aviatrix_transit_firenet_policy" "arm_transit_firenet_policy" {
#   transit_firenet_gateway_name  = aviatrix_transit_gateway.arm_transit_firenet_gateway.gw_name
#   inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.arm_transit_firenet_spoke_gateway.gw_name])
# }
#
# resource "aviatrix_firewall_management_access" "arm_transit_firenet_firewall_management" {
#   transit_firenet_gateway_name      = aviatrix_transit_gateway.arm_transit_firenet_gateway.gw_name
#   management_access_resource_name   = join(":", ["SPOKE", aviatrix_spoke_gateway.arm_transit_firenet_spoke_gateway.gw_name])
# }

#################################################
# Outputs
#################################################
output "arm_transit_firenet_gateway_id" {
  value = aviatrix_transit_gateway.arm_transit_firenet_gateway.id
}
output "arm_transit_firenet_spoke_vnet_id" {
  value = aviatrix_vpc.arm_transit_firenet_spoke_vnet.id
}
output "arm_transit_firenet_spoke_native_peer_id" {
  value = aviatrix_azure_spoke_native_peering.arm_transit_firenet_spoke_native_peer.id
}
output "arm_transit_firenet_inst_id" {
  value = aviatrix_firewall_instance.arm_transit_firenet_inst.id
}
output "arm_firenet_id" {
  value = aviatrix_firenet.arm_firenet.id
}
