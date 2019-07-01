# Terraform regression for creating account (3.4 and onwards)

resource "aviatrix_account" "aws_root_access_account" {
  count              = var.num_account
  cloud_type         = 1
  account_name       = "ROOT-access-account-${count.index}"

  aws_iam            = false
  aws_account_number = var.aws_account_number
  aws_access_key     = var.aws_access_key
  aws_secret_key     = var.aws_secret_key
}
