## aviatrix_vpc

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_vpc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_vpc createVPCTest
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode

  terraform state rm aviatrix_vpc.test_vpc2
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_vpc2 createVPCTest2
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpc.test_vpc3
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpc.test_vpc3 createVPCTest3
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
