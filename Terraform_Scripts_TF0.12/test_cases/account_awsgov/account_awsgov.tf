resource "aviatrix_account" "aws_gov_root_1" {
  account_name            = "aws-gov-root-1"
  cloud_type              = 256
  awsgov_account_number   = var.awsgov_account_num
  awsgov_access_key       = var.awsgov_access_key
  awsgov_secret_key       = var.awsgov_secret_key

  lifecycle {
    ignore_changes = [awsgov_secret_key]
  }
}

output "aws_gov_root_1_id" {
  value = aviatrix_account.aws_gov_root_1.id
}
