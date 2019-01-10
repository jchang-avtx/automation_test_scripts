# transit access account
module "transit_account" {
  source                 = "aviatrix_account"
  mod_max_account        = "${var.transit_account}"
  mod_cloud_type         = "${var.cloud_type}"
  mod_account_name       = "${var.transit_account_name}"
  mod_aws_account_number = "${var.aws_account_number}"
}
# spoke access accounts
module "spoke_account" {
  source                 = "aviatrix_account"
  mod_max_account        = "${var.ondemand_max_account}"
  mod_cloud_type         = "${var.cloud_type}"
  mod_account_name       = "${var.ondemand_act_name}"
  mod_aws_account_number = "${var.aws_account_number}"
}
module "spoke_account2" {
  source                 = "aviatrix_account"
  mod_max_account        = "${var.ondemand_max_account}"
  mod_cloud_type         = "${var.cloud_type}"
  mod_account_name       = "${var.ondemand_act_name}2"
  mod_aws_account_number = "${var.aws_account_number}"
}
module "transit_vpc" {
  source          = "aviatrix_transit"
  providers       = {
      aws = "aws.us-east-1"
  }
  mod_account_name    = "${module.transit_account.accountlist[0]}"
  mod_region          = "us-east-1"
  mod_gw_size         = "${var.transit_gateway_size}"
  mod_name_suffix     = "${var.transit_gateway_name}"
  mod_transit_cidr_prefix = "${var.transit_cidr_prefix}"
  mod_vgw_id          = ""
  mod_bgp_local_as    = ""
  mod_vgw_conn_name   = ""
}

# aviatrix spoke gateway
# trigger for spoke count per account is done per module
# since module doesn't support count
module "ondemand1" {
  source = "ondemand_spoke"
  providers = {
    aws = "aws.us-east-2"
  }
  mod_spoke_region         = "us-east-2"
  mod_cloud_type           = "${var.cloud_type}"
  mod_aws_account_number   = "${var.aws_account_number}"
  mod_ondemand_max_account = "${var.ondemand_max_account}"
  mod_spoke_gw_size        = "${var.ondemand_spoke_gateway_size}"
  mod_name_suffix          = "${var.ondemand_gateway_name}"
  mod_spoke_cidr_prefix    = "${var.ondemand_spoke_cidr_prefix1}"
  mod_transit_gateway      = "${module.transit_vpc.transit_gateway_name}"
  mod_ondemand_act_name    = ["${module.spoke_account.accountlist[0]}","${module.spoke_account.accountlist[1]}","${module.spoke_account.accountlist[2]}","${module.spoke_account.accountlist[3]}","${module.spoke_account.accountlist[4]}","${module.spoke_account.accountlist[5]}","${module.spoke_account.accountlist[6]}","${module.spoke_account.accountlist[7]}","${module.spoke_account.accountlist[8]}","${module.spoke_account.accountlist[9]}"]
}
module "ondemand2" {
  source = "ondemand_spoke"
  providers = {
    aws = "aws.us-east-2"
  }
  mod_spoke_region         = "us-east-2"
  mod_cloud_type           = "${var.cloud_type}"
  mod_aws_account_number   = "${var.aws_account_number}"
  mod_ondemand_max_account = "${var.ondemand_max_account}"
  mod_spoke_gw_size        = "${var.ondemand_spoke_gateway_size}"
  mod_name_suffix          = "${var.ondemand_gateway_name}"
  mod_spoke_cidr_prefix    = "${var.ondemand_spoke_cidr_prefix2}"
  mod_transit_gateway      = "${module.transit_vpc.transit_gateway_name}"
  mod_ondemand_act_name    = ["${module.spoke_account2.accountlist[0]}","${module.spoke_account2.accountlist[1]}","${module.spoke_account2.accountlist[2]}","${module.spoke_account2.accountlist[3]}","${module.spoke_account2.accountlist[4]}","${module.spoke_account2.accountlist[5]}","${module.spoke_account2.accountlist[6]}","${module.spoke_account2.accountlist[7]}","${module.spoke_account2.accountlist[8]}","${module.spoke_account2.accountlist[9]}"]
}
