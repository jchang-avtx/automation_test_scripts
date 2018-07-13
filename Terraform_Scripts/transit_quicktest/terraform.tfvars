vgw_connection_name = "oregon_vgw_bgp_s2c"
vgw_id = "vgw-05e54079c2b80d433"
bgp_local_as = 6510

controller_custom_version = "3.4"
transit_gateway_name = "oregon-transit"
transit_gateway_size = "t2.micro"
transit_subnet = "192.169.0.0/24"
transit_region = "us-west-2"
transit_count = 1
transit_vpc = "vpc-0144ad37d26b895eb"

shared_vpc = "vpc-07563f47372f126e4"
shared_gateway_name = "oregon-shared"
shared_gateway_size = "t2.micro"
shared_region = "us-west-2"
shared_subnet = "10.224.0.0/24"
shared_count = 1

spoke0_vpc = "vpc-05fd98c037cb55486"
spoke0_region = "us-west-2"
spoke0_gateway_name = "oregon-spoke0"
spoke0_subnet = "10.1.0.0/24"

spoke1_vpc = "vpc-05fd98c037cb55486"
spoke1_region = "us-west-2"
spoke1_gateway_name = "oregon-spoke1"
spoke1_subnet = "10.1.1.0/24"

spoke2_vpc = "vpc-05fd98c037cb55486"
spoke2_region = "us-west-2"
spoke2_gateway_name = "oregon-spoke2"
spoke2_subnet = "10.1.2.0/24"

azure_region = "West US 2"
azure_vpc = "vnet2:west_us_2"
azure_subnet = "10.20.0.0/24"
azure_account_name = "EdselARM"

onprem_vpc = "vpc-0cc006ff1126b518a"
onprem_count = 1
onprem_gateway_name = "oregon-OnPrem"
onprem_gateway_size = "t2.micro"
onprem_region = "us-west-2"
onprem_subnet = "172.16.0.0/28"
s2c_remote_subnet = "10.224.0.0/24,10.1.0.0/24,10.1.1.0/24,10.1.2.0/24"

# region parameters
spoke_gateway_size = "t2.micro"
single_region = "us-west-2"
myprefix = "OREGON"
