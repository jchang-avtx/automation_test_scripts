# Manage Aviatrix Transit Network Gateways

resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 223
}

resource "aviatrix_vpc" "oci_transit_gw_vnet_1" {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 16
  name                  = "oci-transit-gw-vnet-1"
  region                = "us-ashburn-1"
}

resource "aviatrix_transit_gateway" "oci_transit_gateway" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-transit-gw"
  # enable_snat        = true # updating SNAT not supported by OCI
  vpc_id              = aviatrix_vpc.oci_transit_gw_vnet_1.name
  vpc_reg             = aviatrix_vpc.oci_transit_gw_vnet_1.region
  gw_size             = var.gw_size
  subnet              = aviatrix_vpc.oci_transit_gw_vnet_1.subnets.0.cidr

  single_az_ha        = var.single_az_ha
  ha_subnet           = aviatrix_vpc.oci_transit_gw_vnet_1.subnets.0.cidr
  ha_gw_size          = var.ha_gw_size

  enable_hybrid_connection  = false # only supports cloud type 1
  connected_transit         = var.tgw_enable_connected_transit # (optional) specify connected transit status (yes or no)
  enable_active_mesh        = false

}

output "oci_transit_gateway_id" {
  value = aviatrix_transit_gateway.oci_transit_gateway.id
}
