# Manage Aviatrix Transit Network Gateways

resource "aviatrix_transit_gateway" "oci_transit_gateway" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-transit-gw"
  # enable_snat        = true # updating SNAT not supported by OCI
  vpc_id              = "OCI-VCN"
  vpc_reg             = "us-ashburn-1"
  gw_size             = var.gw_size
  subnet              = "123.101.0.0/16"

  single_az_ha        = var.single_az_ha
  ha_subnet           = "123.101.0.0/16"
  ha_gw_size          = var.ha_gw_size

  enable_hybrid_connection  = false # only supports cloud type 1
  connected_transit         = var.tgw_enable_connected_transit # (optional) specify connected transit status (yes or no)
  enable_active_mesh        = false

}

output "oci_transit_gateway_id" {
  value = aviatrix_transit_gateway.oci_transit_gateway.id
}
