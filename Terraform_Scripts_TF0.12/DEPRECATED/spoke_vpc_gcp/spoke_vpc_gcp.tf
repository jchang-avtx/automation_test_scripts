# Manage Aviatrix spoke_vpc (Gcloud)

resource "aviatrix_spoke_vpc" "gcloud_spoke_gw" {
  cloud_type      = 4
  account_name    = "GCPAccess"
  gw_name         = "gcloudspokegw"
  vpc_id          = "default"
  vpc_reg         = "us-west2-a"
  vpc_size        = var.gcp_instance_size
  subnet          = "10.168.0.0/20"

  ha_zone         = var.gcp_ha_gw_zone
  ha_gw_size      = var.gcp_ha_gw_size
  enable_nat      = var.toggle_snat
}
