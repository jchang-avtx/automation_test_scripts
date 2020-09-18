## Test case 3: update tag_list from some values to some other values

aws_instance_size     = "t3.micro"
aws_ha_gw_size        = "t3.micro"
aws_gateway_tag_list  = ["k1:v1", "k2:v2", "k3:v3"] # upate tags
single_ip_snat        = false
enable_vpc_dns_server = false
