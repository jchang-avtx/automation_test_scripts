# Manage Aviatrix Transit Gateway with Firewall Network feature

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "aviatrix_vpc" "firenet_vpc" {
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-west-1"
  name = "firenetVPC"
  cidr = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = true
}

resource "aviatrix_transit_gateway" "firenet_transit_gw" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "firenetTransitGW"
  vpc_id              = aviatrix_vpc.firenet_vpc.vpc_id
  vpc_reg             = "us-west-1"
  gw_size             = "c5.xlarge"
  subnet              = aviatrix_vpc.firenet_vpc.subnets.0.cidr
  ha_subnet           = aviatrix_vpc.firenet_vpc.subnets.2.cidr
  ha_gw_size          = "c5.xlarge"

  single_ip_snat              = false
  enable_firenet              = var.toggle_firenet
  enable_hybrid_connection    = true
  connected_transit           = true
  enable_active_mesh          = false
}

output "firenet_transit_gw_id" {
  value = aviatrix_transit_gateway.firenet_transit_gw.id
}
