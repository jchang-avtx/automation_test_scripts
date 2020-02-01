# case 4: enable active mesh

single_ip_snat            = false
single_az_ha              = true
enable_connected_transit  = false
enable_active_mesh        = true

gcp_gw_size     = "n1-standard-1"
gcp_ha_gw_size  = "n1-standard-1"
gcp_ha_gw_zone  = "us-central1-c"
