Description
-----------
Prebuild AWS VPCs and Linux instances (Special for Jenkins)
Specific for Transit Switchover, Peering Switchover, Upgrade, Network Ping, FTP traffic test

-------------------------------------
Single Region = ca-central-1
Transit VPC = 192.169.0.0/24  = vpc-33c82c5b  
Shared  VPC = 10.224.0.0/24 = vpc-95ca2efd
Spoke0  VPC = 10.1.0.0/24 = vpc-1ac92d72
Spoke1  VPC = 10.1.1.0/24 = vpc-d1c82cb9
Spoke2  VPC = 10.1.2.0/24 = vpc-43c92d2b
spoke-azure VNET = 10.0.1.0/24 av-group1-vnet:av-group1 West US
OnPrem  = CIDR 172.16.0.0/16 = vpc-94ca2efc

All in Transit Network HA deployment

terraform plan -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS"
terrafrom apply -auto-approve -var-file=<path_secret_file.tfvars>  -var account_name="EdselAWS" -parallelism=1

terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target=module.spoke_ca_central-1
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target module.shared_services_vpc
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target=module.transit_vpc
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -parallelism=1



