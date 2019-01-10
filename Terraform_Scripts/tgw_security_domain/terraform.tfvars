cloud_type                  = 1
tgw_max_account             = 2
tgw_account_name            = "TGW-account"
transit_account             = 1
transit_account_name        = "transit-account"
transit_gateway_name        = "TGW-transit"
transit_gateway_size        = "t3.micro"
transit_subnet              = "192.168.1.0/24"
transit_vpc                 = "vpc-00bf315a74d78ff41"
ondemand_spoke_gateway_size = "t2.micro"
ondemand_spoke_count        = 1
ondemand_max_account        = 10
ondemand_act_name           = "TGW-ondemand-account"
ondemand_gateway_name       = "TGW-batchT1-1"
ondemand_spoke_cidr_prefix  = "10.10"
regions_list                = ["us-east-1","us-east-2"]
tgw_per_region              = { us-west-1="1", us-west-2="1"}
