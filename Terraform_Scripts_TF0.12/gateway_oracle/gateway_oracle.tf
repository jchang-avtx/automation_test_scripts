# Create and manage an Oracle Cloud gateway

resource "aviatrix_gateway" "oci_gateway" {
  cloud_type          = 16
  account_name        = "OracleAccess"
  gw_name             = "oci-gw"
  vpc_id              = "OCI-VCN"
  vpc_reg             = "us-ashburn-1"
  gw_size             = "VM.Standard2.2"
  subnet              = "123.101.0.0/16"

  enable_snat         = false # updating/ enabling SNAT not supported for OCI (5.0)

  allocate_new_eip    = true

  peering_ha_subnet   = "123.101.0.0/16"
  peering_ha_gw_size  = "VM.Standard2.2"

  single_az_ha        = true
}
