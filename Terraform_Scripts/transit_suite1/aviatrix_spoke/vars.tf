variable "account_name" {}
variable "name_suffix" {}
variable "transit_gateway_name" {}
variable "spoke_region" {}
variable "spoke_gw_size" {}
variable "shared_gw_name" {}

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

