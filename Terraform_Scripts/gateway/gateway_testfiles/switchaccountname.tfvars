# Test order 1: change account names

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################

aviatrix_cloud_account_name     = "2ndaryAccess"
aviatrix_cloud_type_aws = 1
aviatrix_gateway_name   = ["testGW1"]

##############################################
## Singular gateway for faster testing
##############################################
aws_vpc_id = ["vpc-abc123"]
aws_region = ["us-east-1"]
aws_vpc_public_cidr = ["10.0.0.0/24"]
aws_instance = ["t2.micro"]
aws_gateway_tag_list = ["Purpose:Test TF GW1"]
