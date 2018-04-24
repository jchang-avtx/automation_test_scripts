vgw_connection_name = "canada_vgw_bgp_s2c_conn"
vgw_id = "vgw-d9c14fe9"
bgp_local_as = 6510

controller_custom_version = "3.2"
transit_gateway_name = "canada-transit"
transit_gateway_size = "t2.micro"
transit_cidr_prefix = "192.168"
transit_region = "ca-central-1"
transit_count = 1

shared_gateway_name = "canada-shared"
shared_gateway_size = "t2.micro"
shared_region = "ca-central-1"
shared_cidr_prefix = "10.224"
shared_count = 1

onprem_count = 1
onprem_gateway_name = "canada-OnPrem"
onprem_gateway_size = "t2.micro"
onprem_region = "ca-central-1"
onprem_cidr_prefix = "172.16"
s2c_remote_subnet = "10.224.0.0/24,10.45.0.0/24,10.46.0.0/24,10.47.0.0/24,10.48.0.0/24"

# region parameters
spoke_gateway_size = "t2.micro"
single_region = "ca-central-1"
