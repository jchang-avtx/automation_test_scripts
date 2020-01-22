## aviatrix_account (AWS Gov)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/awsgov_account_cred.tfvars -auto-approve
  terraform plan -var-file=/path/awsgov_account_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_account.gov_root
  terraform import -var-file=/path/awsgov_account_cred.tfvars aviatrix_account.gov_root AWSGovRoot
  terraform plan -var-file=/path/awsgov_account_cred.tfvars

  terraform apply -var-file=updateAccount.tfvars -auto-approve
  terraform show

  terraform destroy -auto-approve
```
