# Transit Network with prebuilt AWS VPCs and AWS Linux Configurations

# Create TRANSIT 
module "transit_vpc" {
  source          = "aviatrix_transit"
  providers       = {
      aws = "aws.ca-central-1"
  }
  account_name    = "${var.account_name}"
  region          = "${var.single_region}"
  gw_size         = "${var.transit_gateway_size}"
  name_suffix     = "${var.transit_gateway_name}"
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
      aws = "aws.ca-central-1"
  }
  account_name    = "${var.account_name}"
  region          = "${var.single_region}"
  gw_size         = "${var.shared_gateway_size}"
  name_suffix     = "${var.shared_gateway_name}"
  vpc_id          = "${var.shared_vpc}"
  subnet          = "${var.shared_subnet}"
  transit_gw      = "${module.transit_vpc.transit_gateway_name}"
}
# Create Azure spoke
module "azure_spoke" {
  source          = "aviatrix_azurespoke"
  account_name    = "${var.azure_account_name}"
  transit_gw      = "${module.transit_vpc.transit_gateway_name}"
  shared          = "${module.shared_services_vpc.shared_gateway_name}"
  region          = "${var.azure_region}"
  vpc_id          = "${var.azure_vpc}"
  subnet          = "${var.azure_subnet}"
}
# Create OnPrem spoke
module "onprem" {
  source          = "aviatrix_onprem"
  providers       = {
      aws = "aws.ca-central-1"
  }
  account_name    = "${var.account_name}"
  onprem_gw_name  = "${var.onprem_gateway_name}"
  vgw_id          = "${var.vgw_id}"
  region          = "${var.single_region}"
  onprem_gw_size  = "${var.onprem_gateway_size}"
  name_suffix     = "${var.onprem_gateway_name}"
  vpc_id          = "${var.onprem_vpc}"
  subnet          = "${var.onprem_subnet}"
  remote_subnet   = "${var.s2c_remote_subnet}"
}
module "spoke" {
  source          = "aviatrix_spoke"
  providers       = {
      aws = "aws.ca-central-1"
  }
  account_name    = "${var.account_name}"
  transit_gateway = "${module.transit_vpc.transit_gateway_name}"
  shared_gateway  = "${module.shared_services_vpc.shared_gateway_name}"
  spoke_gw_size   = "${var.spoke_gateway_size}"
  name_suffix     = "${var.spoke_gateway_prefix}"
  spoke_region    = "${var.single_region}"
  spoke0_vpc_id   = "${var.spoke0_vpc}"
  spoke0_subnet   = "${var.spoke0_subnet}"
  spoke1_vpc_id   = "${var.spoke1_vpc}"
  spoke1_subnet   = "${var.spoke1_subnet}"
  spoke2_vpc_id   = "${var.spoke2_vpc}"
  spoke2_subnet   = "${var.spoke2_subnet}"
}
