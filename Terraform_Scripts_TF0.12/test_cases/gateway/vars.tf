variable aws_instance_size {}
variable aws_ha_gw_size {}
variable aws_gateway_tag_list {
  type = list(string)
}
variable single_ip_snat {}
variable enable_vpc_dns_server {}

variable ping_interval {
  type = number
  default = 60
}

variable enable_gov {
  type = bool
  default = false
  description = "Enable to create AWS GovCloud test case"
}
