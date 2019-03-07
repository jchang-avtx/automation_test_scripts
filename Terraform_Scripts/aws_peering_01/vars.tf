variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "avx_account_name_1" {}
variable "avx_account_name_2" {}

variable "aws_vpc_id_1" {}
variable "aws_vpc_id_2" {}
variable "aws_vpc_region_1" {}
variable "aws_vpc_region_2" {}
variable "aws_vpc_rtb_1" {
  type = "list"
}
variable "aws_vpc_rtb_2" {
  type = "list"
}
