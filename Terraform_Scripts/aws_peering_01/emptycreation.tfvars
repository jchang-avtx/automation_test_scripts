# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis: id=8537 for issues with
## This file is also used to test Update test case;; See sections for Valid Input

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
# aws_vpc_rtb_1 = ["all"] # all or rtb-abcd1234 (OPTIONAL) comment out to test if required
# aws_vpc_rtb_2 = ["all"] # all or rtb-wxyz5678 (OPTIONAL) comment out to test if required

##############################################
## INVALID/ EMPTY INPUT
##############################################

# avx_account_name_1 = ""
# avx_account_name_2 = ""
#
# aws_vpc_id_1 = ""
# aws_vpc_id_2 = ""
# aws_vpc_region_1 = ""
# aws_vpc_region_2 = ""
aws_vpc_rtb_1 = ["invalidInput"] # all or rtb-abcd1234
aws_vpc_rtb_2 = ["invalidInput"] # all or rtb-wxyz5678
