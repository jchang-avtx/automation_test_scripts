# transit access account
module "account" {
  source                 = "aviatrix_account"
  mod_max_account        = "${var.transit_account}"
  mod_cloud_type         = "${var.cloud_type}"
  mod_account_name       = "${var.transit_account_name}"
  mod_aws_account_number = "${var.aws_account_number}"
}

# transit network gateway
module "transit_vpc" {
  source          = "aviatrix_transit"
  providers       = {
      aws = "aws.us-east-1"
  }
  mod_account_name    = "${module.account.accountlist[0]}"
  mod_region          = "us-east-1"
  mod_gw_size         = "${var.transit_gateway_size}"
  mod_name_suffix     = "${var.transit_gateway_name}"
  mod_transit_cidr_prefix = "${var.ondemand_transit_cidr_prefix}"
  mod_vgw_id          = ""
  mod_bgp_local_as    = ""
  mod_vgw_conn_name   = ""
}
# spoke gateway
# variable access account and spokes per account
module "ondemand" {
  source = "ondemand_spoke"
  providers = {
    aws = "aws.us-east-2"
  }
  mod_spoke_region         = "us-east-2"
  mod_cloud_type           = "${var.cloud_type}"
  mod_aws_account_number   = "${var.aws_account_number}"
  mod_ondemand_max_account = "${var.ondemand_max_account}"
  mod_ondemand_act_name    = "${var.ondemand_act_name}"
  mod_spoke_count          = "${var.ondemand_spoke_count}"
  mod_spoke_gw_size        = "${var.ondemand_spoke_gateway_size}"
  mod_name_suffix          = "${var.ondemand_gateway_name}"
  mod_spoke_cidr_prefix    = "${var.ondemand_spoke_cidr_prefix}"
  mod_transit_gateway      = "${module.transit_vpc.transit_gateway_name}"
}
