## Initial creation
# Launch a spoke VPC, and join with transit VPC.
# Omit ha_subnet to launch spoke VPC without HA.
# Omit transit_gw to launch spoke VPC without attaching with transit GW.
# (R2.4 cannot test HA due to service limit issue on account)

resource "aviatrix_transit_gateway" "oci_transit_gateway1" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-transit-gw-for-spoke"

  vpc_id              = "OCI-VCN"
  vpc_reg             = "us-ashburn-1"
  gw_size             = "VM.Standard2.2"
  subnet              = "123.101.0.0/16"

  ha_subnet           = "123.101.0.0/16"
  ha_gw_size          = "VM.Standard2.2"

  enable_hybrid_connection  = false # only supports cloud type 1
  connected_transit         = true # (optional) specify connected transit status (yes or no)
  enable_active_mesh        = false
}

resource "aviatrix_transit_gateway" "oci_transit_gateway2" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-transit-gw-for-spoke2"

  vpc_id              = "OCI-VCN"
  vpc_reg             = "us-ashburn-1"
  gw_size             = "VM.Standard2.2"
  subnet              = "123.101.0.0/16"

  ha_subnet           = "123.101.0.0/16"
  ha_gw_size          = "VM.Standard2.2"

  enable_hybrid_connection  = false # only supports cloud type 1
  connected_transit         = true # (optional) specify connected transit status (yes or no)
  enable_active_mesh        = false
}


resource "aviatrix_spoke_gateway" "oci_spoke_gateway" {
  cloud_type        = 16
  account_name      = "OCIAccess"
  gw_name           = "oci-spoke-gw"
  vpc_id            = "OCI-VCN-phoenix"
  vpc_reg           = "us-phoenix-1"
  gw_size           = var.gw_size

  subnet            = "169.69.0.0/16"
  single_az_ha      = true

  ha_subnet         = "169.69.0.0/16"
  ha_gw_size        = var.ha_gw_size
  enable_snat       = false # (Please disable AWS NAT instance before enabling this feature); not supported w insane mode
  enable_active_mesh= false

  transit_gw        = var.transit_gw # optional; comment out if want to test Update from no transitGW attachment to yes
  depends_on        = ["aviatrix_transit_gateway.oci_transit_gateway1", "aviatrix_transit_gateway.oci_transit_gateway2"]
}
