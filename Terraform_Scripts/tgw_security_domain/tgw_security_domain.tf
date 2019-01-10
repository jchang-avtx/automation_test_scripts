# tgw access account
module "account" {
  source                 = "aviatrix_account"
  mod_max_account        = "${var.tgw_max_account}"
  mod_cloud_type         = "${var.cloud_type}"
  mod_account_name       = "${var.tgw_account_name}"
  mod_aws_account_number = "${var.aws_account_number}"
}

module "tgw1" {
  source       = "aviatrix_tgw1"
  mod_regions  = ["${var.regions_list}"]
  mod_act_list = ["${module.account.accountlist[0]}","${module.account.accountlist[1]}"]
}
module "tgw2" {
  source             = "aviatrix_tgw2"
  mod_tgw_per_region = "${var.tgw_per_region}"
}


