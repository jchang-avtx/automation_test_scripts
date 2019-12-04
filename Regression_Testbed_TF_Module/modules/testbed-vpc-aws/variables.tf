# Variable declarations for TF Regression Testbed AWS VPC environment setup

variable "vpc_count" {
	type				= number
	description	= "The number of vpcs to create in the given aws region."
}
variable "resource_name_label" {
	type				= string
	description	= "The label for the resource name."
}
variable "public_key" {
	type				= string
	description	= "Public key used for creating key pair for all instances."
}
variable "pub_hostnum" {
	type				= number
	description = "Number to be used for public ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
}
variable "pri_hostnum" {
	type				= number
	description = "Number to be used for private ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
}
variable "vpc_cidr" {
	type				= list(string)
	description = "The cidr for a vpc."
}
variable "pub_subnet1_cidr" {
	type				= list(string)
  description = "The cidr for public subnet 1."
}
variable "pub_subnet2_cidr" {
	type				= list(string)
  description = "The cidr for public subnet 2."
}
variable "pri_subnet_cidr" {
	type				= list(string)
	description = "The cidr for a private subnet."
}
variable "pub_subnet1_az" {
	type				= list(string)
  description = "The availability zone for public subnet 1."
	default 		= null
}
variable "pub_subnet2_az" {
	type				= list(string)
  description = "The availability zone for public subnet 2."
	default 		= null
}
variable "pri_subnet_az" {
	type				= list(string)
	description = "The availability zone for a private subnet."
	default 		= null
}
variable "ubuntu_ami" {
	type				= string
	description = "AMI of the ubuntu instances"
}
variable "instance_size" {
	type 				= string
	description = "Size of AWS instance."
	default 		= "t2.micro"
}
variable "termination_protection" {
	type				= bool
	description	= "Whether to disable api termination for the ubuntu instances."
}

locals {
	ubuntu_ami = {
		us-east-1      = "ami-04b9e92b5572fa0d1"
		us-east-2      = "ami-0d5d9d301c853a04a"
		us-west-1      = "ami-0dd655843c87b6930"
		us-west-2      = "ami-06d51e91cea0dac8d"
		ca-central-1   = "ami-0d0eaed20348a3389"
    eu-central-1   = "ami-0cc0a36f626a4fdf5"
    eu-west-1      = "ami-02df9ea15c1778c9c"
    eu-west-2      = "ami-0be057a22c63962cb"
    eu-west-3      = "ami-087855b6c8b59a9e4"
    eu-north-1     = "ami-1dab2163"
    ap-east-1      = "ami-59780228"
    ap-southeast-1 = "ami-061eb2b23f9f8839c"
    ap-southeast-2 = "ami-00a54827eb7ffcd3c"
    ap-northeast-1 = "ami-0cd744adeca97abb1"
    ap-northeast-2 = "ami-00379ec40a3e30f87"
    ap-south-1     = "ami-0123b531fc646552f"
    sa-east-1      = "ami-02c8813f1ea04d4ab"
	}
}
