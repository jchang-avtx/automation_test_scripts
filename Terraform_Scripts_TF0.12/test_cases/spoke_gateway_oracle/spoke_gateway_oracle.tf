## Initial creation
# Launch a spoke VPC, and join with transit VPC.
# Omit ha_subnet to launch spoke VPC without HA.
# Omit transit_gw to launch spoke VPC without attaching with transit GW.
# (R2.4 cannot test HA due to service limit issue on account)

resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "random_integer" "vpc2_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "aviatrix_vpc" "oci_vnet_for_transit_1" {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 16
  name                  = "oci-vnet-for-transit-1"
  region                = "us-ashburn-1"
}

resource "aviatrix_vpc" "oci_vnet_for_spoke_1" {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  cloud_type            = 16
  name                  = "oci-vnet-for-spoke-1"
  region                = "us-phoenix-1"
}

resource "aviatrix_transit_gateway" "oci_transit_gateway1" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-transit-gw-for-spoke"

  vpc_id              = aviatrix_vpc.oci_vnet_for_transit_1.name
  vpc_reg             = aviatrix_vpc.oci_vnet_for_transit_1.region
  gw_size             = "VM.Standard2.2"
  subnet              = aviatrix_vpc.oci_vnet_for_transit_1.subnets.0.cidr

  ha_subnet           = aviatrix_vpc.oci_vnet_for_transit_1.subnets.0.cidr
  ha_gw_size          = "VM.Standard2.2"

  enable_hybrid_connection  = false # only supports cloud type 1
  connected_transit         = true # (optional) specify connected transit status (yes or no)
  enable_active_mesh        = false
}

resource "aviatrix_transit_gateway" "oci_transit_gateway2" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-transit-gw-for-spoke2"

  vpc_id              = aviatrix_vpc.oci_vnet_for_transit_1.name
  vpc_reg             = aviatrix_vpc.oci_vnet_for_transit_1.region
  gw_size             = "VM.Standard2.2"
  subnet              = aviatrix_vpc.oci_vnet_for_transit_1.subnets.0.cidr

  ha_subnet           = aviatrix_vpc.oci_vnet_for_transit_1.subnets.0.cidr
  ha_gw_size          = "VM.Standard2.2"

  enable_hybrid_connection  = false # only supports cloud type 1
  connected_transit         = true # (optional) specify connected transit status (yes or no)
  enable_active_mesh        = false
}


resource "aviatrix_spoke_gateway" "oci_spoke_gateway" {
  cloud_type        = 16
  account_name      = "OCIAccess"
  gw_name           = "oci-spoke-gw"
  vpc_id            = aviatrix_vpc.oci_vnet_for_spoke_1.name
  vpc_reg           = aviatrix_vpc.oci_vnet_for_spoke_1.region
  gw_size           = var.gw_size

  subnet            = aviatrix_vpc.oci_vnet_for_spoke_1.subnets.0.cidr
  single_az_ha      = true

  ha_subnet         = aviatrix_vpc.oci_vnet_for_spoke_1.subnets.0.cidr
  ha_gw_size        = var.ha_gw_size
  single_ip_snat    = false # (Please disable AWS NAT instance before enabling this feature); not supported w insane mode
  enable_active_mesh= false

  transit_gw        = var.transit_gw # optional; comment out if want to test Update from no transitGW attachment to yes
  depends_on        = ["aviatrix_transit_gateway.oci_transit_gateway1", "aviatrix_transit_gateway.oci_transit_gateway2"]
}

output "oci_spoke_gateway_id" {
  value = aviatrix_spoke_gateway.oci_spoke_gateway.id
}
