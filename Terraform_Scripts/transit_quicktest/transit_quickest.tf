# Transit Network with prebuilt AWS VPCs and AWS Linux Configurations

# Create TRANSIT 
module "transit_vpc" {
  source          = "aviatrix_transit"
  providers       = {
      aws = "aws.us-west-2"
  }
  account_name    = "${var.account_name}"
  region          = "${var.transit_region}"
  gw_size         = "${var.transit_gateway_size}"
  transit_gateway = "${var.transit_gateway_name}"
  subnet          = "${var.transit_subnet}"
  vgw_id          = "${var.vgw_id}"
  bgp_local_as    = "${var.bgp_local_as}"
  vgw_conn_name   = "${var.vgw_connection_name}"
  vpc_id          = "${var.transit_vpc}"
}

# Create Shared spoke
module "shared_services_vpc" {
  source          = "aviatrix_shared"
  providers       = {
      aws = "aws.us-west-2"
  }
  account_name    = "${var.account_name}"
  region          = "${var.shared_region}"
  gw_size         = "${var.shared_gateway_size}"
  name_suffix     = "${var.shared_gateway_name}"
  vpc_id          = "${var.shared_vpc}"
  subnet          = "${var.shared_subnet}"
  transit_gateway = "${module.transit_vpc.transit_gateway_name}"
}
# Create Azure spoke
module "azure_spoke" {
  source          = "aviatrix_azurespoke"
  account_name    = "${var.azure_account_name}"
  transit_gateway = "${module.transit_vpc.transit_gateway_name}"
  shared          = "${module.shared_services_vpc.shared_gateway_name}"
  region          = "${var.azure_region}"
  vpc_id          = "${var.azure_vpc}"
  subnet          = "${var.azure_subnet}"
}
# Create OnPrem spoke
module "onprem" {
  source          = "aviatrix_onprem"
  providers       = {
      aws = "aws.us-west-2"
  }
  account_name    = "${var.account_name}"
  onprem_gw_name  = "${var.onprem_gateway_name}"
  vgw_id          = "${var.vgw_id}"
  region          = "${var.onprem_region}"
  onprem_gw_size  = "${var.onprem_gateway_size}"
  name_suffix     = "${var.onprem_gateway_name}"
  vpc_id          = "${var.onprem_vpc}"
  subnet          = "${var.onprem_subnet}"
  remote_subnet   = "${var.s2c_remote_subnet}"
}
module "spoke0" {
  source          = "aviatrix_spoke"
  providers       = {
      aws = "aws.us-west-2"
  }
  account_name    = "${var.account_name}"
  transit_gateway = "${module.transit_vpc.transit_gateway_name}"
  spoke_region    = "${var.spoke0_region}"
  spoke_gw_size   = "${var.spoke_gateway_size}"
  name_suffix     = "${var.spoke0_gateway_name}"
  shared_gateway  = "${module.shared_services_vpc.shared_gateway_name}"
  vpc_id          = "${var.spoke0_vpc}"
  subnet          = "${var.spoke0_subnet}"
}
