variable "aws_cloud_region" {
  default = "us-west-2"
}
variable "aws_site_region" {
  type = list(string)
}
variable "deploy" {
  default = false
}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_aws_access_account" {}
variable "ssh_user" {
  default = "ubuntu"
}
variable "public_key" {}
variable "private_key" {}
variable "pre_shared_key" {}
variable "phase_1_authentication" {}
variable "phase_2_authentication" {}
variable "phase_1_dh_groups" {}
variable "phase_2_dh_groups" {}
variable "phase_1_encryption" {}
variable "phase_2_encryption" {}
variable "region_names" {
  type = map(string)
  default = {
    us-east-1      = "NorthVirginia"
    us-east-2      = "Ohio"
    us-west-1      = "NorthCalifornia"
    us-west-2      = "Oregon"
    af-south-1     = "CapeTown"
    ap-east-1      = "HongKong"
    ap-south-1     = "Mumbai"
    ap-northeast-2 = "Seoul"
    ap-southeast-1 = "Singapore"
    ap-southeast-2 = "Sydney"
    ap-northeast-1 = "Tokyo"
    ca-central-1   = "Canada"
    eu-central-1   = "Frankfurt"
    eu-west-1      = "Ireland"
    eu-west-2      = "London"
    eu-south-1     = "Milan"
    eu-west-3      = "Paris"
    eu-north-1     = "Stockholm"
    me-south-1     = "Bahrain"
    sa-east-1      = "SaoPaulo"
  }
}
