vgw_connection_name = "canada_vgw_bgp_s2c"
vgw_id = "vgw-05e54079c2b80d433"
bgp_local_as = 6580

controller_custom_version = "3.4"
transit_gateway_name = "canada-transit"
transit_gateway_size = "t2.micro"
transit_subnet = "192.169.0.0/24"
transit_count = 1
transit_vpc = "vpc-33c82c5b"

shared_vpc = "vpc-95ca2efd"
shared_gateway_name = "canada-shared"
shared_gateway_size = "t2.micro"
shared_subnet = "10.224.0.0/24"
shared_count = 1

spoke0_vpc = "vpc-1ac92d72"
spoke0_subnet = "10.1.0.0/24"

spoke1_vpc = "vpc-d1c82cb9"
spoke1_subnet = "10.1.1.0/24"

spoke2_vpc = "vpc-43c92d2b"
spoke2_subnet = "10.1.2.0/24"

azure_region = "West US 2"
azure_vpc = "west_us_2-vnet:west_us_2"
azure_subnet = "10.1.102.0/24"
azure_account_name = "EdselARM"

onprem_vpc = "vpc-94ca2efc"
onprem_count = 1
onprem_gateway_name = "canada-OnPrem"
onprem_gateway_size = "t2.micro"
onprem_region = "ca-central-1"
onprem_subnet = "172.16.0.0/28"
s2c_remote_subnet = "10.224.0.0/24,10.1.0.0/24,10.1.1.0/24,10.1.2.0/24"

# region parameters
spoke_gateway_size   = "t2.micro"
spoke_gateway_prefix = "canada-spoke"
single_region = "ca-central-1"
