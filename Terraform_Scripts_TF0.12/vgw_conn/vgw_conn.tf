# Manage Aviatrix Controller TransitGW to VGW Connection

resource "aviatrix_transit_gateway" "aws_transit_gw" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "AWStransitGW1"
  vpc_id          = "vpc-0c32b9c3a144789ef"
  vpc_reg         = "us-east-1"
  gw_size         = "t2.micro"
  subnet          = "10.0.1.32/28"

  enable_hybrid_connection  = true
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.bgp_manual_spoke_advertise_cidrs_list
}

resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name                         = "test_connection_tgw_vgw"
  gw_name                           = aviatrix_transit_gateway.aws_transit_gw.gw_name
  vpc_id                            = aviatrix_transit_gateway.aws_transit_gw.vpc_id
  bgp_vgw_id                        = "vgw-0cf3a3302ac5857a8"
  bgp_vgw_account                   = aviatrix_transit_gateway.aws_transit_gw.account_name
  bgp_vgw_region                    = aviatrix_transit_gateway.aws_transit_gw.vpc_reg
  bgp_local_as_num                  = 100
}

resource "aviatrix_transit_gateway" "arm_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "ARMtransitGW"
  vpc_id              = "TransitVNet:TransitRG"
  vpc_reg             = "Central US"
  gw_size             = "Standard_B1ms"
  subnet              = "10.2.0.0/24"
  single_az_ha        = true

  enable_hybrid_connection  = false
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.bgp_manual_spoke_advertise_cidrs_list
}

resource "aviatrix_transit_gateway" "gcp_transit_gw" {
  cloud_type          = 4
  account_name        = "GCPAccess"
  gw_name             = "gcptransitgw"
  vpc_id              = "gcptestvpc"
  vpc_reg             = "us-central1-c"
  gw_size             = "n1-standard-1"
  subnet              = "10.128.0.0/20"
  single_az_ha        = true

  enable_hybrid_connection  = false
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.bgp_manual_spoke_advertise_cidrs_list
}

resource "aviatrix_transit_gateway" "oci_transit_gw" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "OCItransitGW"
  vpc_id              = "OCI-VCN"
  vpc_reg             = "us-ashburn-1"
  gw_size             = "VM.Standard2.2"
  subnet              = "123.101.0.0/16"
  single_az_ha        = true

  enable_hybrid_connection  = false
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.bgp_manual_spoke_advertise_cidrs_list
}

output "test_vgw_conn_id" {
  value = aviatrix_vgw_conn.test_vgw_conn.id
}
