# Terraform regression for creating account (3.4 and onwards)
## Comment out either key block or the role block depending if account is IAM-role based or not
## Do this for this file, vars.tf and terraform.tfvars

resource "aviatrix_account" "access_account" {
    count              = "${var.num_account}"
    cloud_type         = "${var.cloud_type}"
    account_name       = "${var.myname}-${count.index}"
    aws_iam            = "${var.aws_iam}"
    aws_account_number = "${var.aws_account_number}"

    ## Key block
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key     = "${var.aws_secret_key}"

    ## Role block : IAM-role based
    aws_role_app       = "${var.aws_role_app_arn}"
    aws_role_ec2       = "${var.aws_role_ec2_arn}"
}
