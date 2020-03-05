resource "aviatrix_transit_gateway" "gcp_transit_gateway" {
  cloud_type    = 4
  account_name  = "GCPAccess"
  gw_name       = "gcp-transit-gateway"
  vpc_id        = "gcptestvpc"
  vpc_reg       = "us-central1-c"
  gw_size       = var.gcp_gw_size
  subnet        = "10.128.0.0/20"

  ha_zone       = var.gcp_ha_gw_zone
  ha_gw_size    = var.gcp_ha_gw_size

  single_ip_snat= var.single_ip_snat
  single_az_ha  = var.single_az_ha

  connected_transit   = var.enable_connected_transit
  enable_active_mesh  = var.enable_active_mesh
}

output "gcp_transit_gateway_id" {
  value = aviatrix_transit_gateway.gcp_transit_gateway.id
}
