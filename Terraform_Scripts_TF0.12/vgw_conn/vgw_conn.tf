# Manage Aviatrix Controller TransitGW to VGW Connection

resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 223
}
resource "random_integer" "vnet1_cidr_int" {
  count = 3
  min = 1
  max = 223
}
resource "random_integer" "vnet2_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "aws_vgw_conn_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "aws-vgw-conn-vpc"
  region                = "us-east-1"
}
resource "aviatrix_vpc" "arm_vgw_conn_vnet" {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, random_integer.vnet1_cidr_int[2].result, "0/24"])
  cloud_type            = 8
  name                  = "arm-vgw-conn-vnet"
  region                = "Central US"
}
resource "aviatrix_vpc" "oci_vgw_conn_vnet" {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet2_cidr_int[0].result, random_integer.vnet2_cidr_int[1].result, random_integer.vnet2_cidr_int[2].result, "0/24"])
  cloud_type            = 16
  name                  = "oci-vgw-conn-vnet"
  region                = "us-ashburn-1"
}

resource "aviatrix_transit_gateway" "aws_transit_gw" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "AWStransitGW1"
  vpc_id          = aviatrix_vpc.aws_vgw_conn_vpc.vpc_id
  vpc_reg         = aviatrix_vpc.aws_vgw_conn_vpc.region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.aws_vgw_conn_vpc.subnets.4.cidr

  enable_hybrid_connection  = true
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.toggle_advertise_transit_cidr == true ? "10.0.1.32/8" : null
}

resource "aws_vpn_gateway" "us_east_vgw_conn" {
  tags = {
    Name = "us-east-vgw-conn"
  }
  amazon_side_asn = 64512
}

resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name                   = "test_connection_tgw_vgw"
  gw_name                     = aviatrix_transit_gateway.aws_transit_gw.gw_name
  vpc_id                      = aviatrix_transit_gateway.aws_transit_gw.vpc_id
  bgp_vgw_id                  = aws_vpn_gateway.us_east_vgw_conn.id
  bgp_vgw_account             = aviatrix_transit_gateway.aws_transit_gw.account_name
  bgp_vgw_region              = aviatrix_transit_gateway.aws_transit_gw.vpc_reg
  bgp_local_as_num            = 100
}

resource "aviatrix_transit_gateway" "arm_transit_gw" {
  cloud_type          = 8
  account_name        = "AzureAccess"
  gw_name             = "ARMtransitGW"
  vpc_id              = aviatrix_vpc.arm_vgw_conn_vnet.vpc_id
  vpc_reg             = aviatrix_vpc.arm_vgw_conn_vnet.region
  gw_size             = "Standard_B1ms"
  subnet              = aviatrix_vpc.arm_vgw_conn_vnet.subnets.0.cidr
  single_az_ha        = true

  enable_hybrid_connection  = false
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.toggle_advertise_transit_cidr == true ? "10.0.1.32/8" : null
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
  bgp_manual_spoke_advertise_cidrs  = var.toggle_advertise_transit_cidr == true ? "10.0.1.32/8" : null
}

resource "aviatrix_transit_gateway" "oci_transit_gw" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "OCItransitGW"
  vpc_id              = aviatrix_vpc.oci_vgw_conn_vnet.vpc_id
  vpc_reg             = aviatrix_vpc.oci_vgw_conn_vnet.region
  gw_size             = "VM.Standard2.2"
  subnet              = aviatrix_vpc.oci_vgw_conn_vnet.subnets.0.cidr
  single_az_ha        = true

  enable_hybrid_connection  = false
  connected_transit         = true

  enable_advertise_transit_cidr     = var.toggle_advertise_transit_cidr
  bgp_manual_spoke_advertise_cidrs  = var.toggle_advertise_transit_cidr == true ? "10.0.1.32/8" : null
}

output "test_vgw_conn_id" {
  value = aviatrix_vgw_conn.test_vgw_conn.id
}
