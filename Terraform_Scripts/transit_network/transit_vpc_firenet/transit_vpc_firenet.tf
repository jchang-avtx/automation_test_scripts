# Manage Aviatrix Transit Gateway with Firewall Network feature

# resource "aviatrix_vpc" "firenet_vpc" {
#   cloud_type = 1
#   account_name = "PrimaryAccessAccount"
#   region = "us-west-1"
#   name = "firenet_vpc"
#   cidr = "15.15.15.0/24"
#   aviatrix_transit_vpc = false
#   aviatrix_firenet_vpc = true
# }

resource "aviatrix_transit_vpc" "firenet_transit_gw" {
  cloud_type = 1
  account_name = "PrimaryAccessAccount"
  gw_name = "firenetTransitGW"
  vpc_id = "vpc-firenetvpcid" # FirenetVPC
  vpc_reg = "us-west-1"
  vpc_size = "c5.xlarge"
  subnet = "15.15.15.32/28" # us-west-1a
  ha_subnet = "15.15.15.64/28" # us-west-1b
  ha_gw_size = "c5.xlarge"

  enable_nat = "no"
  enable_firenet_interfaces = "${var.toggle_firenet}"
  enable_hybrid_connection = true
  connected_transit = "yes"
  # depends_on = ["aviatrix_vpc.firenet_vpc"] ## not needed because VPC is generated
}
