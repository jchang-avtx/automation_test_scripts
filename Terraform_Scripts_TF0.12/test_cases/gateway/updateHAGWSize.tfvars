## Test case 6: update ha-gateway size from t2.micro to t2.small

aws_instance_size     = "t2.small"
aws_ha_gw_size        = "t2.small" # t2.micro -> t2.small
aws_gateway_tag_list  = []
enable_snat           = false
enable_vpc_dns_server = false
