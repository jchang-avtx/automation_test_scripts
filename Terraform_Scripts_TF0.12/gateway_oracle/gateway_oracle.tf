# Create and manage an Oracle Cloud gateway

resource "aviatrix_gateway" "oci_gateway" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-gw"
  vpc_id              = "OCI-VCN"
  vpc_reg             = "us-ashburn-1"
  gw_size             = var.oci_gw_size
  subnet              = "123.101.0.0/16"

  enable_snat         = false # updating/ enabling SNAT not supported for OCI (5.0)

  allocate_new_eip    = true

  peering_ha_subnet   = var.oci_ha_gw_subnet
  peering_ha_gw_size  = var.oci_ha_gw_size

  single_az_ha        = true
}

output "oci_gateway_id" {
  value = aviatrix_gateway.oci_gateway.id
}
