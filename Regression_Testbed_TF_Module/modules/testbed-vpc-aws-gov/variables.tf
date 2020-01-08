# Variable declarations for TF Regression Testbed AWS VPC environment setup

# Providers
variable "aws_gov_access_key" {
  type        = string
  description = "AWS Gov account's access key."
}
variable "aws_gov_secret_key" {
  type        = string
  description = "AWS Gov account's secret key."
}

variable "termination_protection" {
	type				= bool
	description = "Whether to enable termination protection for ec2 instances."
}
variable "resource_name_label" {
	type				= string
	description	= "The label for the resouce name."
}
variable "owner" {
	type 				= string
	description = "Name of the owner for the AWS resources. Optional."
	default 		= null
}

# AWS VPC
variable "vpc_public_key" {
  type        = string
  description = "Public key used for creating key pair for all instances."
}
variable "pub_hostnum" {
  type        = number
  description = "Number to be used for public ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
}
variable "pri_hostnum" {
  type        = number
  description = "Number to be used for private ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
}

# US-WEST-1 Region
variable "vpc_count_gov_west" {
  type        = number
  description = "The number of vpcs to create in the given aws region."
}
variable "vpc_cidr_gov_west" {
  type        = list(string)
  description = "The cidr for a vpc."
}
variable "pub_subnet1_cidr_gov_west" {
  type        = list(string)
  description = "The cidr for public subnet 1."
}
variable "pub_subnet2_cidr_gov_west" {
  type        = list(string)
  description = "The cidr for public subnet 2."
}
variable "pri_subnet_cidr_gov_west" {
  type        = list(string)
  description = "The cidr for a private subnet."
}
variable "pub_subnet1_az_gov_west" {
  type        = list(string)
  description = "The availability zone for public subnet 1."
}
variable "pub_subnet2_az_gov_west" {
  type        = list(string)
  description = "The availability zone for public subnet 2."
}
variable "pri_subnet_az_gov_west" {
  type        = list(string)
  description = "The availability zone for a private subnet."
}
variable "ubuntu_ami_gov_west" {
  type        = string
  description = "AMI of the ubuntu instances"
}

# US-EAST-1 Region
variable "vpc_count_gov_east" {
  type        = number
  description = "The number of vpcs to create in the given aws region."
}
variable "vpc_cidr_gov_east" {
  type        = list(string)
  description = "The cidr for a vpc."
}
variable "pub_subnet1_cidr_gov_east" {
  type        = list(string)
  description = "The cidr for public subnet 1."
}
variable "pub_subnet2_cidr_gov_east" {
  type        = list(string)
  description = "The cidr for public subnet 2."
}
variable "pri_subnet_cidr_gov_east" {
  type        = list(string)
  description = "The cidr for a private subnet."
}
variable "pub_subnet1_az_gov_east" {
  type        = list(string)
  description = "The availability zone for public subnet 1."
}
variable "pub_subnet2_az_gov_east" {
  type        = list(string)
  description = "The availability zone for public subnet 2."
}
variable "pri_subnet_az_gov_east" {
  type        = list(string)
  description = "The availability zone for a private subnet."
}
variable "ubuntu_ami_gov_east" {
  type        = string
  description = "AMI of the ubuntu instances"
}
