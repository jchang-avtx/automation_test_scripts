# initial create

single_ip_snat            = true
single_az_ha              = false
enable_connected_transit  = true
enable_active_mesh        = false

gcp_gw_size     = "n1-standard-1"
gcp_ha_gw_size  = "n1-standard-1"
gcp_ha_gw_zone  = "us-central1-c"
gcp_ha_gw_subnet = "172.20.0.0/16"
