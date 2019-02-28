# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input

## Additional test cases:
# - peering_ha_eip : new parameter

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################
## VALID INPUT
##############################################

aviatrix_cloud_type_aws = "1"
aviatrix_cloud_account_name  = "PrimaryAccessAccount"
# gateway_names       = ["peeringHA-gw1","peeringHA-gw2"]
aws_region          = "us-east-1"
aws_instance        = "t2.micro"
aws_vpc_id          = ["vpc-abc123","vpc-def456"]
aws_vpc_public_cidr = ["10.0.0.0/24","11.0.0.0/24"]
avx_peering_eip     = ["11.11.11.11", "12.12.12.12"]

# enable_ha           = "yes"
# enable_cluster      = "no"

##############################################
## EMPTY / INVALID INPUT
##############################################
avx_peering_eip     = ["invalidEIP", "invalidEIP2"]
## dealing specifically with Tunnel resource

gateway_names = ["", ""] # empty

enable_ha = "" # empty
# enable_ha = "notYesorNo" # invalid

enable_cluster = "" # empty
# enable_cluster = "notYesorNo" # invalid
