## Test case 2: Update transit_vpc's enable_hybrid_connection (disable)

##############################################

aviatrix_cloud_account_name = "PrimaryAccessAccount"
aviatrix_cloud_type_aws = 1
aviatrix_gateway_name = "testtransitGW1"
aviatrix_enable_nat = "yes"

aws_vpc_id = "vpc-abc123" # make sure this is the transitVPC id; see specifications in the docs
aws_region = "us-east-1"
aws_instance = "t2.small" # from t2.micro to t2.small
aws_vpc_public_cidr = "123.0.0.0/24"

## HA parameters
aviatrix_ha_subnet = "123.0.0.0/24" # (optional) HA subnet. Setting to empty/unset will disable HA. Setting to valid subnet will create an HA gateway in the subnet
aviatrix_ha_gw_size = "t2.small" # (optional) HA gw size. Mandatory if HA is enabled (ex. "t2.micro")

tgw_enable_hybrid = false # (optional) enable to prep for TGW attachment; allows you to skip Step5 in TGW orchestrator ## UPDATED TO TEST THIS
tgw_enable_connected_transit = "no" # (optional) specify connected transit status
