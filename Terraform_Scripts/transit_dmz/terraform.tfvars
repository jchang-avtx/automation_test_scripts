# controller secret credentials are hidden
vgw_connection_name       = "nvirginia_vgw_bgp_s2c"
vgw_id                    = "vgw-0f26ed22866f77ac6"
bgp_local_as              = 6586

controller_custom_version = "4.2"
transit_gateway_name      = "nvirginia-transit"
transit_gateway_size      = "t3.small"
transit_public_subnet     = "192.192.192.80/28"
transit_count             = 1
transit_vpc_id            = "vpc-09ec26ad34d685e1a"
single_region             = "us-east-1"

onprem_vpc                = "vpc-0d78176851c3a4eca"
onprem_count              = 1
onprem_gateway_name       = "nvirginia-OnPrem"
onprem_gateway_size       = "t2.small"
onprem_region             = "us-east-1"
onprem_subnet             = "172.16.0.80/28"
s2c_remote_subnet         = "10.224.0.0/24,10.1.0.0/24,10.1.1.0/24,10.1.2.0/24,10.224.3.0/24,10.224.4.0/24,192.150.0.0/16"


