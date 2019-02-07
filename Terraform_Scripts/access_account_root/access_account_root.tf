# Terraform regression for creating account (3.4 and onwards)

resource "aviatrix_account" "access_account" {
    count              = "${var.num_account}"
    cloud_type         = "${var.cloud_type}"
    account_name       = "${var.myname}-${count.index}"
    aws_iam            = "${var.aws_iam}"
    aws_account_number = "${var.aws_account_number}"
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key     = "${var.aws_secret_key}"
}
