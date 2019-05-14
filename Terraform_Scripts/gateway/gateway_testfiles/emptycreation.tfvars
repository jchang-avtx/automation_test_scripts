# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input

##############################################

aviatrix_cloud_account_name     = "PrimaryAccessAccount"
aviatrix_cloud_type_aws = 1
aviatrix_gateway_name   = ["testGW1"] # case 1

##############################################
## VALID INPUT
##############################################
## Singular gateway for faster testing
# aws_vpc_id = ["vpc-abc123"]
# aws_region = ["us-east-1"]
# aws_vpc_public_cidr = ["10.0.0.0/24"]
# aws_instance = ["t2.micro"]
# aws_gateway_tag_list = ["Purpose:Test TF GW1"] # optional. can comment out if do not want

##############################################
## EMPTY/ INVALID INPUT
##############################################
aviatrix_cloud_account_name     = ""
aviatrix_cloud_type_aws = 0
aviatrix_gateway_name   = [""] # case 1
aviatrix_gateway_name  = ["", ""] # comment out either gateway_name if testing 1 or 2

## one GW
aws_vpc_id = [""]
aws_region = [""]
aws_vpc_public_cidr = [""]
aws_instance = [""]
aws_gateway_tag_list = ["PurposeTest TF GW1"] # invalid input because no :
aws_gateway_tag_list = [""] # empty
