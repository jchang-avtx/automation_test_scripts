## Test case 1: disable SNAT

aws_instance_size     = "t2.micro"
aws_ha_gw_size        = "t2.micro"
aws_gateway_tag_list  = []
single_ip_snat        = false # disabled SNAT
enable_vpc_dns_server = false
