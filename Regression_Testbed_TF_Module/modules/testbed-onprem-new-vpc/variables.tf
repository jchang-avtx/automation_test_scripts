# Variable declarations for testbed-onprem-new-vpc module
variable "resource_name_label" {
  type        = string
  description = "Resource name label."
}

variable "gw_name" {
  type        = string
  description = "Name of Aviatrix Onprem GW. Default is 'onprem-gw'."
  default     = "onprem-gw"
}

variable "s2c_connection_name" {
  type        = string
  description = "Name of onprem S2C connection. Default is 'onprem-s2c'."
  default     = "onprem-s2c"
}

variable "account_name" {
  type        = string
  description = "Access account name in Aviatrix controller."
}

variable "onprem_vpc_cidr" {
  type        = string
  description = "VPC cidr for Onprem VPC."
}

variable "pub_subnet_cidr" {
  type        = string
  description = "Subnet cidr to launch Aviatrix GW and public ubuntu instance into."
}

variable "pub_subnet_az" {
  type        = string
  description = "Subnet availability zone. Optional."
  default     = null
}

variable "pri_subnet_cidr" {
  type        = string
  description = "Subnet cidr to launch private ubuntu instance into."
}

variable "pri_subnet_az" {
  type        = string
  description = "Subnet availability zone. Optional."
  default     = null
}

variable "pub_hostnum" {
  type        = number
  description = "Numer to be used for public ubuntu instance private ip host part."
}

variable "pri_hostnum" {
  type        = number
  description = "Numer to be used for private ubuntu instance private ip host part."
}

variable "termination_protection" {
  type        = bool
  description = "Whether to turn on EC2 instance termination protection."
}

variable "public_key" {
  type        = string
  description = "Public key to ssh into ubuntu instances."
}

variable "ubuntu_ami" {
  type        = string
  description = "AMI of ubuntu instances. Optional."
  default     = null
}

variable "remote_subnet_cidr" {
  type        = list(string)
  description = "Remote subnet cidr for Site2Cloud connection."
}

variable "local_subnet_cidr" {
  type        = list(string)
  description = "Local subnet cidr for Site2Cloud connection. Optional."
  default     = []
}

variable "static_route_cidr" {
  type        = list(string)
  description = "List of static routes to add to VPN."
}

variable "asn" {
  type        = number
  description = "ASN for the AWS VGW. Default is 64512."
  default     = null

# default ubuntu 18.04 ami
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
