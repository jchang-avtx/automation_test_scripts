Description
-----------
Prebuild AWS VPCs and Linux instances

Single Region = ca-central-1
Transit VPC = 192.169.0.0/24    
Shared  VPC = 10.224.0.0/24
Spoke0  VPC = 10.1.0.0/24
Spoke1  VPC = 10.1.1.0/24
Spoke2  VPC = 10.1.2.0/24
spoke-azure VNET = 10.0.1.0/24 av-group1-vnet:av-group1 West US

All in Transit Network HA deployment

terraform plan -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS"
terrafrom apply -auto-approve -var-file=<path_secret_file.tfvars>  -var account_name="EdselAWS"

terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target=module.spoke_ca_central-1
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target module.shared_services_vpc
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS" -target=module.transit_vpc
terraform destroy -force -var-file=<path_secret_file.tfvars> -var account_name="EdselAWS"



