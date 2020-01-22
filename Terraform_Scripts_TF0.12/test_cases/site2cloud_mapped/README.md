## aviatrix_site2cloud (mapped)

## DEPRECATED
* test stage integrated with **site2cloud_unmapped** module

---

### Usage
```
  // NOTE: depends on the gateways created in site2cloud_unmapped test case

  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_site2cloud.s2c_test4
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_site2cloud.s2c_test4 s2c_test_conn_name_4~vpc-04ca29a568bf2b35f
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve

  dir(s2c) {
    terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
  }
```
