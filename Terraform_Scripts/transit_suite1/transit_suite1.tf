# Transit Network with prebuilt AWS VPCs and AWS Linux Configurations

# Create TRANSIT 
module "transit_vpc" {
  source = "aviatrix_transit"
  providers = {
    aws = "aws.ca-central-1"
  }
  account_name = "${var.account_name}"
  vpc_count = "${var.transit_count}"
  region = "${var.transit_region}"
  gw_size = "${var.transit_gateway_size}"
  name_suffix = "${var.transit_gateway_name}"
  cidr_prefix = "${var.transit_cidr_prefix}"
  vgw_id = "${var.vgw_id}"
  vpc_name = "transit"
  bgp_local_as = "${var.bgp_local_as}"
  vgw_connection_name = "${var.vgw_connection_name}"
}

# Create Shared spoke
module "shared_services_vpc" {
  source = "aviatrix_shared"
  providers = {
    aws = "aws.ca-central-1"
  }
  account_name = "${var.account_name}"
  vpc_count = "${var.shared_count}"
  region = "${var.shared_region}"
  gw_size = "${var.shared_gateway_size}"
  name_suffix = "${var.shared_gateway_name}"
  cidr_prefix = "${var.shared_cidr_prefix}"
  vpc_name = "shared"
  transit_gw = "${var.transit_gateway_name}"
}
# Create OnPrem spoke
module "onprem" {
  source = "aviatrix_onprem"
  providers = {
    aws = "aws.ca-central-1"
  }
  account_name = "${var.account_name}"
  onprem_count = "${var.onprem_count}"
  onprem_gw_name = "${var.onprem_gateway_name}"
  vgw_id = "${var.vgw_id}"
  region = "${var.onprem_region}"
  onprem_gw_size = "${var.onprem_gateway_size}"
  name_suffix = "${var.onprem_gateway_name}"
  onprem_cidr_prefix = "${var.onprem_cidr_prefix}"
  remote_subnet = "${var.s2c_remote_subnet}"
}
module "spoke_ca_central-1" {
  source = "aviatrix_spoke"
  providers = {
    aws = "aws.ca-central-1"
  }
  account_name = "${var.account_name}"
  transit_gateway_name = "${var.transit_gateway_name}"
  spoke_region = "ca-central-1"
  spoke_gw_size = "${var.spoke_gateway_size}"
  name_suffix = "canada-ca-central-1"
  shared_gw_name = "${var.shared_gateway_name}"
}
