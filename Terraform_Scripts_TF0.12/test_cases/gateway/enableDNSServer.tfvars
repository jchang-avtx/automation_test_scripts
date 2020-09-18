## Test case 7: enable_vpc_dns_server

aws_instance_size     = "t3.small"
aws_ha_gw_size        = "t3.small"
aws_gateway_tag_list  = []
single_ip_snat        = false
enable_vpc_dns_server = true # false -> true
