# Create and manage an Oracle Cloud gateway

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "aviatrix_vpc" "oci_gw_vnet_1" {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 16
  name                  = "oci-gw-vnet-1"
  region                = "us-ashburn-1"
}

resource "aviatrix_gateway" "oci_gateway" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-gw"
  vpc_id              = aviatrix_vpc.oci_gw_vnet_1.name
  vpc_reg             = aviatrix_vpc.oci_gw_vnet_1.region
  gw_size             = var.oci_gw_size
  subnet              = aviatrix_vpc.oci_gw_vnet_1.subnets.0.cidr

  single_ip_snat      = false # updating/ enabling SNAT not supported for OCI (5.0)

  allocate_new_eip    = true

  peering_ha_subnet   = aviatrix_vpc.oci_gw_vnet_1.subnets.0.cidr
  peering_ha_gw_size  = var.oci_ha_gw_size

  single_az_ha        = true
}

output "oci_gateway_id" {
  value = aviatrix_gateway.oci_gateway.id
}
