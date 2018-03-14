variable "account_name" {}
variable "account_password" {}
variable "account_email" {}
variable "aws_account_number" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vgw_connection_name" {}
variable "bgp_local_as" {}
variable "controller_ip" {}
variable "controller_username" {}
variable "controller_password" {}
variable "static_transit_gateway_name" {}
variable "t2instance" {}
variable "region1" {}
variable "region2" {}
variable "region3" {}
variable "transit" {}
variable "spoke_gateways" {}
variable "shared_gateways" {}

#AWS
#variable "AWS_REGION" {}
variable "AMI" {
  type = "map"
  default = {
    ca-central-1 = "ami-018b3065"
    us-east-1    = "ami-aa2ea6d0"
    us-east-2    = "ami-82f4dae7"
    us-west-1    = "ami-45ead225"
    us-west-2    = "ami-0def3275"

  }
}
variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}
