# Manage Aviatrix Controller TransitGW to VGW Connection

resource "aviatrix_transit_gateway" "test_transit_gw" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "testtransitGW1"
  vpc_id          = "vpc-0c32b9c3a144789ef"
  vpc_reg         = "us-east-1"
  gw_size         = "t2.micro"
  subnet          = "10.0.1.32/28"

  enable_hybrid_connection  = true
  connected_transit         = true
}

resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name                         = "test_connection_tgw_vgw"
  gw_name                           = aviatrix_transit_gateway.test_transit_gw.gw_name
  vpc_id                            = aviatrix_transit_gateway.test_transit_gw.vpc_id
  bgp_vgw_id                        = "vgw-0cf3a3302ac5857a8"
  bgp_vgw_account                   = aviatrix_transit_gateway.test_transit_gw.account_name
  bgp_vgw_region                    = aviatrix_transit_gateway.test_transit_gw.vpc_reg
  bgp_local_as_num                  = 100
  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.bgp_manual_spoke_advertise_cidrs_list
  depends_on                        = ["aviatrix_transit_gateway.test_transit_gw"]
}
