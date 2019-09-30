resource "aviatrix_transit_gateway" "insane_transit_gw" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "insaneTransitGW1"

  vpc_id              = "vpc-0c32b9c3a144789ef"
  vpc_reg             = "us-east-1"
  gw_size             = var.gw_size
  subnet              = "10.0.1.128/26"

  insane_mode         = true
  insane_mode_az      = "us-east-1a"
  ha_subnet           = "10.0.1.192/26"
  ha_insane_mode_az   = "us-east-1a"
  ha_gw_size          = var.aviatrix_ha_gw_size

  allocate_new_eip    = false
  eip                 = "34.239.41.40"
  ha_eip              = "3.213.178.197"

  enable_hybrid_connection  = var.tgw_enable_hybrid
  connected_transit         = var.tgw_enable_connected_transit
  enable_active_mesh        = false
  enable_vpc_dns_server     = var.enable_vpc_dns_server
}
