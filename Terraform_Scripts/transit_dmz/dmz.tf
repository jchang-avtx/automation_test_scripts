# Create TRANSIT
module "cluster0" {
  source          = "aviatrix_transit"
  providers       = {
      aws = "aws.ca-central-1"
  }
  account_name    = "${var.aviatrix_account_name}"
  region          = "${var.single_region}"
  gw_size         = "${var.transit_gateway_size}"
  name_suffix     = "${var.transit_gateway_name}"
  subnet          = "${var.transit_public_subnet}"
  vgw_id          = "${var.vgw_id}"
  bgp_local_as    = "${var.bgp_local_as}"
  vgw_conn_name   = "${var.vgw_connection_name}"
  vpc_id          = "${var.transit_vpc_id}"
}
# don't need this because i need GCP spoke connected to main transit
#module "cluster0_spoke" {
#  source          = "aviatrix_spoke"
#  providers       = {
#      aws = "aws.ca-central-1"
#  }
#  account_name    = "${var.aviatrix_account_name}"
#  transit_gateway = "${var.transit_gateway_name}"
#  spoke_gw_size   = "t2.micro"
#  name_suffix     = "spoke1"
#  spoke_region    = "us-east-1"
#  spoke0_vpc_id   = "vpc-061574025ccd39360"
#  spoke0_subnet   = "10.20.0.32/28"
#}


# Create OnPrem 
module "onprem" {
  source          = "aviatrix_onprem"
  providers       = {
      aws = "aws.ca-central-1"
  }
  account_name    = "${var.aviatrix_account_name}"
  onprem_gw_name  = "${var.onprem_gateway_name}"
  vgw_id          = "${var.vgw_id}"
  region          = "${var.single_region}"
  onprem_gw_size  = "${var.onprem_gateway_size}"
  name_suffix     = "${var.onprem_gateway_name}"
  vpc_id          = "${var.onprem_vpc}"
  subnet          = "${var.onprem_subnet}"
  remote_subnet   = "${var.s2c_remote_subnet}"
}

