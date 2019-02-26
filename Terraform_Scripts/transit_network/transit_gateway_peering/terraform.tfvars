# initial creation for Aviatrix transit gateway peering between 2 TGWs

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

aviatrix_transit_gateway_1 = "transitGW1"
aviatrix_transit_gateway_2 = "transitGW2"

aviatrix_cloud_account_name = "PrimaryAccessAccount"
aviatrix_cloud_type_aws = 1
aviatrix_enable_nat = "yes"

aws_vpc_id = ["vpc-1234", "vpc-5678"] # make sure this is the transitVPC id; see specifications in the docs
aws_region = ["us-east-1", "us-west-1"]
aws_instance = "t2.micro"
aws_vpc_public_cidr = ["10.0.0.0/28", "11.0.0.0/28"]

tag_list = ["k1:v1","k2:v2"]
tgw_enable_hybrid = false # (optional) sign of readiness for TGW connection (ex. false)
tgw_enable_connected_transit = "yes" # (optional) specify connected transit status
