# Variables for AWS Client module

variable "region" {
  type        = string
  description = "Name of region to launch Ubuntu client"
}
variable "access_key" {
  type        = string
  description = "AWS access key"
}
variable "secret_key" {
  type        = string
  description = "AWS secret key"
}
variable "deploy" {
  type        = bool
  description = "Whether to deploy resource in this region or not"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy resources"
}
variable "public_key" {
  type        = string
  description = "Public key for creating Ubuntu client"
}
variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch Ubuntu client"
}
variable "ubuntu_ami" {
  type        = map(string)
  description = "Ubuntu-18.04 AMI for different regions"
	default     = {
		us-east-1      = "ami-0ac80df6eff0e70b5"
		us-east-2      = "ami-0a63f96e85105c6d3"
		us-west-1      = "ami-0d705db840ec5f0c5"
		us-west-2      = "ami-003634241a8fcdec0"
    af-south-1     = "ami-079652134906bcbad"
    ap-east-1      = "ami-c42464b5"
    ap-south-1     = "ami-02d55cb47e83a99a0"
    ap-northeast-2 = "ami-0d777f54156eae7d9"
    ap-southeast-1 = "ami-063e3af9d2cc7fe94"
    ap-southeast-2 = "ami-0bc49f9283d686bab"
    ap-northeast-1 = "ami-0cfa3caed4b487e77"
		ca-central-1   = "ami-065ba2b6b298ed80f"
    eu-central-1   = "ami-0d359437d1756caa8"
    eu-west-1      = "ami-089cc16f7f08c4457"
    eu-west-2      = "ami-00f6a0c18edb19300"
    eu-south-1     = "ami-08bb6fa4a2d8676d4"
    eu-west-3      = "ami-0e11cbb34015ff725"
    eu-north-1     = "ami-0f920d75f0ce2c4bb"
    me-south-1     = "ami-0ca656ad4cf917e1f"
    sa-east-1      = "ami-0faf2c48fc9c8f966"
	}
}
