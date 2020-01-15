resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 223
}

resource "aviatrix_vpc" "insane_transit_gw_vpc" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "insane-transit-gw-vpc"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_transit_gateway" "insane_transit_gw" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "insaneTransitGW1"

  vpc_id              = aviatrix_vpc.insane_transit_gw_vpc.vpc_id
  vpc_reg             = aviatrix_vpc.insane_transit_gw_vpc.region
  gw_size             = var.gw_size
  subnet              = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "1.128/26"])

  single_az_ha        = var.single_az_ha
  insane_mode         = true
  insane_mode_az      = "us-east-1a"
  ha_subnet           = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "1.192/26"])
  ha_insane_mode_az   = "us-east-1a"
  ha_gw_size          = var.aviatrix_ha_gw_size

  allocate_new_eip    = false
  eip                 = "52.1.80.143"
  ha_eip              = "54.226.163.231"

  enable_hybrid_connection  = var.tgw_enable_hybrid
  connected_transit         = var.tgw_enable_connected_transit
  enable_active_mesh        = false
  enable_vpc_dns_server     = var.enable_vpc_dns_server
}

output "insane_transit_gw_id" {
  value = aviatrix_transit_gateway.insane_transit_gw.id
}
