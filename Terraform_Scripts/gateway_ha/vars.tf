# variable "aviatrix_controller_ip" {}
# variable "aviatrix_controller_username" {}
# variable "aviatrix_controller_password" {}

variable "aws_instance_size" {}
variable "aws_ha_gw_size" {}
variable "aws_gateway_tag_list" {
  type = "list"
}
variable "enable_nat" {}
