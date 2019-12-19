additional_cidrs = "10.9.0.0/16,10.11.0.0/16"

aws_dnat_policy_src_ip        = "21.0.0.0/24"
aws_dnat_policy_src_port      = 53
aws_dnat_policy_dst_ip        = "22.0.0.0/24"
aws_dnat_policy_dst_port      = 54
aws_dnat_policy_protocol      = "tcp"
aws_dnat_policy_interface     = "eth0"
aws_dnat_policy_connection    = "None"
aws_dnat_policy_mark          = 71
aws_dnat_policy_new_src_ip    = "23.0.0.0"
aws_dnat_policy_new_src_port  = 55
aws_dnat_policy_exclude_rtb   = data.aws_route_table.design_rtb.id

arm_dnat_policy_src_ip        = "21.0.0.0/24"
arm_dnat_policy_src_port      = 53
arm_dnat_policy_dst_ip        = "22.0.0.0/24"
arm_dnat_policy_dst_port      = 54
arm_dnat_policy_protocol      = "udp"
arm_dnat_policy_interface     = "eth0"
arm_dnat_policy_connection    = "None"
arm_dnat_policy_mark          = 71
arm_dnat_policy_new_src_ip    = "23.0.0.0"
arm_dnat_policy_new_src_port  = 55
