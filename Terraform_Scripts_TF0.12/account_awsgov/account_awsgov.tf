resource "aviatrix_account" "gov_root" {
  account_name            = "AWSGovRoot"
  cloud_type              = 256
  awsgov_account_number   = var.awsgov_account_num
  awsgov_access_key       = var.awsgov_access_key
  awsgov_secret_key       = var.awsgov_secret_key
}

output "gov_root_id" {
  value = aviatrix_account.gov_root.id
}
