# case 1: enable single AZHA

enable_snat               = true
single_az_ha              = true
enable_connected_transit  = true
enable_active_mesh        = false

gcp_gw_size     = "n1-standard-1"
gcp_ha_gw_size  = "n1-standard-1"
gcp_ha_gw_zone  = "us-central1-c"
