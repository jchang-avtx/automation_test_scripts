## aviatrix_site2cloud (unmapped)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_site2cloud.s2c_test4
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_site2cloud.s2c_test2 s2c_test_conn_name_2~vpc-04ca29a568bf2b35f
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  // only destroy the s2c connections ; re-use gw's in s2c (mapped) testing
  terraform destroy -var-file=/path/provider_cred.tfvars -target=aviatrix_site2cloud.s2c_test -auto-approve
```
