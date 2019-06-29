## aviatrix_account (Azure)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/azure_account_cred.tfvars -auto-approve
  terraform plan -detailed-exitcode
  terraform show

  terraform state rm aviatrix_account.azure_access_account1
  terraform import aviatrix_account.azure_access_account1 AzureAccess
  terraform plan

  terraform apply -var-file=switchApp.tfvars -auto-approve
  terraform show

  terraform destroy -auto-approve
```

* currently working on adding update test and import
