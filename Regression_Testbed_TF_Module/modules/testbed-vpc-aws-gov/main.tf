# Terraform configuration file to set up the AWS environment in GOV cloud
#
# Each VPC: 2 public subnets, 1 private subnet, 2 public rtb, 1 private rtb
#						1 public ubuntu instance, 1 private ubuntu instance
#						eip assigned to instances
#						temination protection enabled
#						ssh and icmp open to 0.0.0.0/0

provider "aws" {
  version       = "~> 2.7"
  region        = "us-gov-west-1"
	access_key 		= var.aws_gov_access_key
	secret_key 		= var.aws_gov_secret_key
  alias         = "gov-west"
}

module "aws-vpc-gov-west" {
  source          	    = "../testbed-vpc-aws"
  providers = {
    aws = aws.gov-west
  }
  vpc_count             = var.vpc_count_gov_west
  resource_name_label   = var.resource_name_label
	pub_hostnum						= var.pub_hostnum
  pri_hostnum           = var.pri_hostnum
  vpc_cidr              = var.vpc_cidr_gov_west
  pub_subnet1_cidr      = var.pub_subnet1_cidr_gov_west
  pub_subnet2_cidr      = var.pub_subnet2_cidr_gov_west
  pri_subnet_cidr       = var.pri_subnet_cidr_gov_west
  pub_subnet1_az      	= var.pub_subnet1_az_gov_west
  pub_subnet2_az      	= var.pub_subnet2_az_gov_west
  pri_subnet_az       	= var.pri_subnet_az_gov_west
  ubuntu_ami            = var.ubuntu_ami_gov_west
  public_key            = var.vpc_public_key
	termination_protection = var.termination_protection
}

provider "aws" {
  version       = "~> 2.7"
  region        = "us-gov-east-1"
	access_key 		= var.aws_gov_access_key
	secret_key 		= var.aws_gov_secret_key
  alias         = "gov-east"
}

module "aws-vpc-gov-east" {
  source          	    = "../testbed-vpc-aws"
  providers = {
    aws = aws.gov-east
  }
  vpc_count             = var.vpc_count_gov_east
  resource_name_label   = var.resource_name_label
	pub_hostnum						= var.pub_hostnum
  pri_hostnum           = var.pri_hostnum
  vpc_cidr              = var.vpc_cidr_gov_east
  pub_subnet1_cidr      = var.pub_subnet1_cidr_gov_east
  pub_subnet2_cidr      = var.pub_subnet2_cidr_gov_east
  pri_subnet_cidr       = var.pri_subnet_cidr_gov_east
  pub_subnet1_az      	= var.pub_subnet1_az_gov_east
  pub_subnet2_az      	= var.pub_subnet2_az_gov_east
  pri_subnet_az       	= var.pri_subnet_az_gov_east
  ubuntu_ami            = var.ubuntu_ami_gov_east
  public_key            = var.vpc_public_key
	instance_size	     		= "t3.nano"
	termination_protection = var.termination_protection
}
