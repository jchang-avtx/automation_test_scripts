## aviatrix_account (Azure)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/azure_account_cred.tfvars -auto-approve
  terraform plan -var-file=/path/azure_account_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_account.azure_access_account1
  terraform import -var-file=/path/azure_account_cred.tfvars aviatrix_account.azure_access_account1 AzureAccess
  terraform plan -var-file=/path/azure_account_cred.tfvars

  terraform apply -var-file=switchApp.tfvars -auto-approve
  terraform show

  terraform destroy -var-file=switchApp.tfvars -auto-approve
```

* currently working on adding import
