Description
-----------
Prebuild AWS VPCs and Linux instances (Special for Jenkins)
Specific for Transit Switchover, Peering Switchover, Upgrade, Network Ping, FTP traffic test

-------------------------------------
Region=us-west-2 (for quick test only)
EdselGlobalVGW = vgw-05e54079c2b80d433
Transit = CIDR 192.169.0.0/16, SUBNET 192.169.0.0/24 = vpc-0144ad37d26b895eb
Shared  = CIDR 10.224.0.0/16, SUBNET 10.224.0.0/24 = vpc-07563f47372f126e4
Spoke0  = CIDR 10.1.0.0/16, SUBNET 10.1.0.0/24 = vpc-05fd98c037cb55486
Azure   = SUBNET 10.1.102.0/24 = west_us_2-vnet:west_us_2   (West US 2)
OnPrem  = CIDR 172.16.0.0/16, SUBNET 172.16.0.0/28 = vpc-00c0aa8fb232782ff

All in Transit Network HA deployment

terraform plan -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS"
terrafrom apply -auto-approve -var-file=<path_secret_file.tfvars>  -var account_name="EdselAWS"

terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target=module.spoke_ca_central-1
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target module.shared_services_vpc
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target=module.transit_vpc
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS"



