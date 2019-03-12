## Test case: Update existing peering connection
## Only run this AFTER initial creation using the original 'terraform.tfvars'
## Will fail. cannot update existing connection

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## Please input valid other vpc (and/or account names if necessary) to 'establish new' connection
avx_account_name_1 = "AviatrixAccount3"
avx_account_name_2 = "AviatrixAccount4"

aws_vpc_id_1 = "vpc-ghi8901"
aws_vpc_id_2 = "vpc-jkl1011"
aws_vpc_region_1 = "us-west-1"
aws_vpc_region_2 = "us-west-1"
aws_vpc_rtb_1 = ["all"] # all or rtb-abcd1234
aws_vpc_rtb_2 = ["all"] # all or rtb-wxyz5678
