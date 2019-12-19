variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

######################
# SNAT
######################
# AWS
variable "aws_snat_policy_src_ip" {
  default = "13.0.0.0/24"
}
variable "aws_snat_policy_src_port" {
  default = 440
}
variable "aws_snat_policy_dst_ip" {
  default = "14.0.0.0/24"
}
variable "aws_snat_policy_dst_port" {
  default = 441
}
variable "aws_snat_policy_protocol" {
  default = "tcp"
}
variable "aws_snat_policy_interface" {
  default = "eth0"
}
variable "aws_snat_policy_connection" {
  default = "None"
}
variable "aws_snat_policy_mark" {
  default = 69
}
variable "aws_snat_policy_new_src_ip" {
  default = "15.0.0.0-15.0.0.1"
}
variable "aws_snat_policy_new_src_port" {
  default = 443
}
# variable "aws_snat_policy_exclude_rtb" {
#   default = data.aws_route_table.sdnat_spoke_aws_rtb.id
# }

# ARM
variable "arm_snat_policy_src_ip" {
  default = "13.0.0.0/24"
}
variable "arm_snat_policy_src_port" {
  default = 440
}
variable "arm_snat_policy_dst_ip" {
  default = "14.0.0.0/24"
}
variable "arm_snat_policy_dst_port" {
  default = 441
}
variable "arm_snat_policy_protocol" {
  default = "udp"
}
variable "arm_snat_policy_interface" {
  default = "eth0"
}
variable "arm_snat_policy_connection" {
  default = "None"
}
variable "arm_snat_policy_mark" {
  default = 69
}
variable "arm_snat_policy_new_src_ip" {
  default = "15.0.0.0-15.0.0.1"
}
variable "arm_snat_policy_new_src_port" {
  default = 443
}
# variable "arm_snat_policy_exclude_rtb" {
#   default = join(":", [data.azurerm_route_table.sdnat_spoke_arm_rtb.name, data.azurerm_route_table.sdnat_spoke_arm_rtb.resource_group_name])
# }


######################
# DNAT
######################
# AWS
variable "aws_dnat_policy_src_ip" {
  default = "19.0.0.0/24"
}
variable "aws_dnat_policy_src_port" {
  default = 50
}
variable "aws_dnat_policy_dst_ip" {
  default = "20.0.0.0/24"
}
variable "aws_dnat_policy_dst_port" {
  default = 51
}
variable "aws_dnat_policy_protocol" {
  default = "udp"
}
variable "aws_dnat_policy_interface" {
  default = "eth0"
}
variable "aws_dnat_policy_connection" {
  default = "None"
}
variable "aws_dnat_policy_mark" {
  default = 70
}
variable "aws_dnat_policy_new_src_ip" {
  default = "21.0.0.0"
}
variable "aws_dnat_policy_new_src_port" {
  default = 52
}
# variable "aws_dnat_policy_exclude_rtb" {
#   default = data.aws_route_table.sdnat_spoke_aws_rtb.id
# }

# ARM
variable "arm_dnat_policy_src_ip" {
  default = "19.0.0.0/24"
}
variable "arm_dnat_policy_src_port" {
  default = 50
}
variable "arm_dnat_policy_dst_ip" {
  default = "20.0.0.0/24"
}
variable "arm_dnat_policy_dst_port" {
  default = 51
}
variable "arm_dnat_policy_protocol" {
  default = "tcp"
}
variable "arm_dnat_policy_interface" {
  default = "eth0"
}
variable "arm_dnat_policy_connection" {
  default = "None"
}
variable "arm_dnat_policy_mark" {
  default = 70
}
variable "arm_dnat_policy_new_src_ip" {
  default = "21.0.0.0"
}
variable "arm_dnat_policy_new_src_port" {
  default = 52
}
# variable "arm_dnat_policy_exclude_rtb" {
#   default = join(":", [data.azurerm_route_table.sdnat_spoke_arm_rtb.name, data.azurerm_route_table.sdnat_spoke_arm_rtb.resource_group_name])
# }
