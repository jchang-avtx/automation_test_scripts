## Test case 5: update gateway size from t3.micro to t2.small

aws_instance_size     = "t3.small" # t3.micro -> t3.small
aws_ha_gw_size        = "t3.micro"
aws_gateway_tag_list  = []
single_ip_snat        = false
enable_vpc_dns_server = false
