variable "aws_instance_size" {}
variable "aws_ha_gw_size" {}
variable "aws_gateway_tag_list" {
  type = "list"
}
variable "enable_snat" {}
variable "enable_vpc_dns_server" {}
