resource google_compute_address gcloud_gw_ip {
  name = "gcloud-gw-ip"
}

resource google_compute_address gcloud_ha_gw_ip {
  name = "gcloud-ha-gw-ip"
}

resource aviatrix_gateway gcloud_gw {
  cloud_type      = 4
  account_name    = "GCPAccess"
  gw_name         = "gcloud-gw"
  vpc_id          = "default"
  vpc_reg         = "us-west2-c"
  gw_size         = "n1-standard-1"
  subnet          = "10.168.0.0/20"

  peering_ha_gw_size  = var.gcp_ha_gw_size
  peering_ha_subnet   = var.gcp_ha_gw_subnet
  peering_ha_zone     = var.gcp_ha_gw_zone

  # Mantis 15989: GCP supports allocating EIP
  allocate_new_eip = false
  eip              = google_compute_address.gcloud_gw_ip.address
  peering_ha_eip   = var.enable_ha == true ? google_compute_address.gcloud_ha_gw_ip.address : null
}

output gcloud_gw_id {
  value = aviatrix_gateway.gcloud_gw.id
}
