## Comment out either key block or the role block depending if account is IAM-role based or not
## Do this for this file, vars.tf and terraform.tfvars

variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "num_account" {}

variable "cloud_type" {}
variable "myname" {}
variable "aws_iam" {}
variable "aws_account_number" {}

## Key block
variable "aws_access_key" {}
variable "aws_secret_key" {}

## Role block : IAM-role based
variable "aws_role_app_arn" {}
variable "aws_role_ec2_arn" {}
