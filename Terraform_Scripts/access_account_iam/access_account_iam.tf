# Terraform regression for creating account (3.4 and onwards) through IAM

resource "aviatrix_account" "access_account" {
  count = "${var.num_account}"
  cloud_type = "${var.cloud_type}"
  account_name = "${var.access_account_name}-${count.index}"
  aws_account_number = "${var.aws_account_number}"
  aws_iam = "true"

  aws_role_app = "${var.aws_iam_role_app}"
  aws_role_ec2 = "${var.aws_iam_role_ec2}"
}
