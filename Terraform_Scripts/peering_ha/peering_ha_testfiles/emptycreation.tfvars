# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################
## VALID INPUT
##############################################

aviatrix_cloud_type_aws = "1"
aviatrix_cloud_account_name  = "PrimaryAccessAccount"
# gateway_names       = ["peeringHA-gw1","peeringHA-gw2"]
# enable_ha           = "yes"
aws_vpc_id          = ["vpc-abc123","vpc-def456"]
aws_vpc_public_cidr = ["10.0.0.0/24","11.0.0.0/24"]
aws_region          = "us-east-1"
aws_instance        = "t2.micro"

# enable_cluster      = "no"

##############################################
## EMPTY / INVALID INPUT
##############################################
## dealing specifically with Tunnel resource

gateway_names = ["", ""] # empty

enable_ha = "" # empty
# enable_ha = "notYesorNo" # invalid

enable_cluster = "" # empty
# enable_cluster = "notYesorNo" # invalid
