# intial creation for Aviatrix Transit GW

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

aviatrix_cloud_account_name = "PrimaryAccessAccount"
aviatrix_cloud_type_aws = 1
aviatrix_gateway_name = "testtransitGW1"

aws_vpc_id = "vpc-abc123" # make sure this is the transitVPC id; see specifications in the docs
aws_region = "us-east-1"
aws_instance = "t2.micro"
aws_vpc_public_cidr = "10.0.0.0/24"
