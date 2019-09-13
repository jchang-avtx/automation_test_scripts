resource "aviatrix_transit_gateway" "gcp_transit_gateway" {
  cloud_type    = 4
  account_name  = "GCPAccess"
  gw_name       = "gcloudtransitgw"
  vpc_id        = "gcptestvpc"
  vpc_reg       = "us-central1-c"
  gw_size       = var.gcp_gw_size
  subnet        = "10.128.0.0/20"

  ha_subnet     = "10.128.0.0/20"
  ha_gw_size    = var.gcp_ha_gw_size

  enable_snat   = var.enable_snat

  connected_transit   = var.enable_connected_transit
  enable_active_mesh  = var.enable_active_mesh
}
