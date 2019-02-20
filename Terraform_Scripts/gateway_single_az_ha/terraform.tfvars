## initial creation

## Additional test cases:
## - Refresh, Updating single_az_ha from 'disabled' to 'enabled'

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

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

       aviatrix_single_az_ha = "enabled" # comment out to test disabled; default is off; or testing Additional#1

##############################################
## EMPTY/ INVALID INPUT
##############################################
# aviatrix_single_az_ha = "" # empty input
# aviatrix_single_az_ha = "invalid input" # invalid input
