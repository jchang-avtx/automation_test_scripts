## Test case 2: Update spoke_vpc size

##############################################

aviatrix_cloud_account_name = "PrimaryAccessAccount"
aviatrix_cloud_type_aws = 1
aviatrix_gateway_name = "spoke-gw-01"

aws_vpc_id = "vpc-abc123"
aws_region = "us-east-1"
aws_instance = "t2.small" ## t2.micro to t2.small
aws_vpc_public_cidr = "123.0.0.0/24"

aviatrix_ha_subnet = "123.0.0.0/24"
aviatrix_ha_gw_size = "t2.micro"
aviatrix_enable_nat = "yes"

aviatrix_transit_gw = "transitGW2"
tag_list = ["k1:v1","k2:v2"]
