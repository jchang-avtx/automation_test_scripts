## Test case: Create/ update route table

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT
##############################################

avx_account_name_1 = "AviatrixAccount1"
avx_account_name_2 = "AviatrixAccount2"

aws_vpc_id_1 = "vpc-abc1234"
aws_vpc_id_2 = "vpc-def4567"
aws_vpc_region_1 = "us-west-1"
aws_vpc_region_2 = "us-west-1"

##############################################
## INVALID INPUT
##############################################
aws_vpc_rtb_1 = ["invalidInput"] # all or rtb-abcd1234
aws_vpc_rtb_2 = ["invalidInput"] # all or rtb-wxyz5678
