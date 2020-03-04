## aviatrix_vpc

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_aws_vpc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_aws_vpc test-aws-vpc
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode

  terraform state rm aviatrix_vpc.test_aws_transit_vpc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_aws_transit_vpc test-aws-transit-vpc
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_aws_firenet_vpc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_aws_firenet_vpc test-aws-firenet-vpc
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_gcp_vpc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_gcp_vpc test-gcp-vpc
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_arm_vnet
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_arm_vnet test-arm-vnet
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_arm_firenet_vnet
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_arm_firenet_vnet test-arm-firenet-vnet
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
