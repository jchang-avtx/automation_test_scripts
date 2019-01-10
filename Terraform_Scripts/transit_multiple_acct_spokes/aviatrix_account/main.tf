resource "aviatrix_account" "transit_access_account" {
  count              = "${var.mod_max_account}"
  cloud_type         = "${var.mod_cloud_type}"
  account_name       = "${var.mod_account_name}-${count.index}"
  aws_account_number = "${var.mod_aws_account_number}"
  aws_iam            = "true"
}
