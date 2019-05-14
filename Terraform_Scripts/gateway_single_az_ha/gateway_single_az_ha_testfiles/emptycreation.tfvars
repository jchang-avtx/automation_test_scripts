## Test case: Test empty input

## Additional test cases:
## - Refresh, Updating single_az_ha from 'disabled' to 'enabled'

##############################################
## VALID INPUT
##############################################
     aviatrix_cloud_type_aws = 1
aviatrix_cloud_account_name  = "AccessAccountName"
      aviatrix_gateway_name  = "single-AZ-ha-GW"

                  aws_vpc_id = "vpc-abc123"
                  aws_region = "us-east-1"
                aws_instance = "t2.micro"
         aws_vpc_public_cidr = "10.0.0.0/24"

        aws_gateway_tag_list = ["k1:v1", "k2:v2"]

##############################################
## EMPTY/ INVALID INPUT
##############################################
aviatrix_single_az_ha = "" # empty input
