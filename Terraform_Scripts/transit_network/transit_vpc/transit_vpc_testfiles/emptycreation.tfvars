# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## There will be bugs and Terraform crashing; Please see Mantis: id=8192 for issue with ha_subnet, ha_gw_size

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

# aviatrix_cloud_account_name = "PrimaryAccessAccount"
# aviatrix_cloud_type_aws = 1
# aviatrix_gateway_name = "testtransitGW1"
#
# aws_vpc_id = "vpc-0c32b9c3a144789ef" # make sure this is the transitVPC; see specifications in the docs
# aws_region = "us-east-1"
# aws_instance = "t2.micro"
# aws_vpc_public_cidr = "10.0.0.0/24"
#
# ## HA parameters
# aviatrix_ha_subnet = "10.0.0.0/24"# (optional) HA subnet. Setting to empty/unset will disable HA. Setting to valid subnet will create an HA gateway in the subnet
# aviatrix_ha_gw_size = "t2.micro"# (optional) HA gw size. Mandatory if HA is enabled (ex. "t2.micro")
#
# tgw_enable_hybrid = true # (optional) sign of readiness for TGW connection (ex. false)

##############################################
## EMPTY / INVALID INPUT
##############################################
aviatrix_cloud_account_name = ""
# aviatrix_cloud_account_name = "as;dlfkj" # nonexistent account name
aviatrix_cloud_type_aws = 3 # 1 is for AWS. We only currently support 1
aviatrix_gateway_name = "" # empty gw name

aws_vpc_id = "" # empty
# aws_vpc_id = "vpc-123abc" # invalid vpc id
aws_region = "" # empty
# aws_region = "us-east-#" # invalid region
aws_instance = "" # empty
# aws_instance = "t2.invalid" # invalid instance size
aws_vpc_public_cidr = "" # empty
# aws_vpc_public_cidr = "1000000/100" # invalid subnet cidr

# HA parameters (OPTIONAL parameters must use invalid values, not empty .. bc theyre optional.)
# Blank optional parameter values usually default to just off, unless otherwise specified
aviatrix_ha_subnet = "asdf"# (optional) correctly catches incorrect input to not enable HA
aviatrix_ha_gw_size = "asdf"# (optional) HA gw size. Mandatory if HA is enabled (ex. "t2.micro")

tgw_enable_hybrid = false # (optional) sign of readiness for TGW connection (ex. false)
