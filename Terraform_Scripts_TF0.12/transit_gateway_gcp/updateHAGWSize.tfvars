# case 5: update HA GW size

enable_snat               = false
enable_connected_transit  = false
enable_active_mesh        = true

gcp_gw_size     = "n1-standard-2"
gcp_ha_gw_size  = "n1-standard-2"
gcp_ha_gw_zone  = "us-central1-c"