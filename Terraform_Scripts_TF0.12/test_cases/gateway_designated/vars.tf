variable "additional_cidrs" {
  description = "If route entries falls within these ranges; gw will maintain route table internally and entries will not be added"
  default = "10.10.0.0/16,10.8.0.0/16,10.9.0.0/16,10.11.0.0/16"
}

# AWS
variable "aws_dnat_policy_src_cidr" {
  default = "19.0.0.0/24"
}
variable "aws_dnat_policy_src_port" {
  default = 50
}
variable "aws_dnat_policy_dst_cidr" {
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
variable "aws_dnat_policy_dnat_ips" {
  default = "21.0.0.0"
}
variable "aws_dnat_policy_dnat_port" {
  default = 52
}

# ARM
variable "arm_dnat_policy_src_cidr" {
  default = "19.0.0.0/24"
}
variable "arm_dnat_policy_src_port" {
  default = 50
}
variable "arm_dnat_policy_dst_cidr" {
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
variable "arm_dnat_policy_dnat_ips" {
  default = "21.0.0.0"
}
variable "arm_dnat_policy_dnat_port" {
  default = 52
}
