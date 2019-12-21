# Terraform regression for creating account (3.4 and onwards)

resource "aviatrix_account" "aws_iam_access_account" {
  count              = 3
  cloud_type         = 1
  account_name       = join("-", ["Test-IAM-Access-Account", count.index])

  aws_iam            = true
  aws_account_number = var.aws_account_number
  aws_role_app       = var.aws_iam_role_app
  aws_role_ec2       = var.aws_iam_role_ec2
}
