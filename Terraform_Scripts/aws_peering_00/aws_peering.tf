# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
       username = "${var.controller_username}"
       password = "${var.controller_password}"
}

module "create_vpc1" {
  source = "create_aws_vpc"
  providers = {
    aws = "aws.us-east-1"
  }
  region = "${var.vpc_reg1}"
  vpc_cidr_block = "${var.vpc_cidr_block1}"
}
module "create_vpc2" {
  source = "create_aws_vpc"
  providers = {
    aws = "aws.us-east-2"
  }
  vpc_cidr_block = "${var.vpc_cidr_block2}"
  region = "${var.vpc_reg2}"
}


# Create account with IAM roles
resource "aviatrix_account" "account1" {
  account_name = "${var.access_account1}"
  cloud_type = 1
  aws_iam = "true"
  aws_account_number = "${var.aws_account_number}"
}
resource "aviatrix_account" "account2" {
  account_name = "${var.access_account2}"
  cloud_type = 1
  aws_iam = "true"
  aws_account_number = "${var.aws_account_number}"
}
# Create encrypteed peering between two aviatrix gateway
resource "aviatrix_aws_peer" "AWS_PEERING"{
     vpc_id1 = "${module.create_vpc1.vpcID}"
     vpc_reg1 = "${var.vpc_reg1}"
     vpc_id2 = "${module.create_vpc2.vpcID}"
     vpc_reg2 = "${var.vpc_reg2}"
     account_name1 = "${aviatrix_account.account1.account_name}"
     account_name2 = "${aviatrix_account.account2.account_name}"
}
