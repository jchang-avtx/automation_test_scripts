## aviatrix_account_user

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/account_user_cred.tfvars -auto-approve
  terraform plan -var-file=/path/account_user_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_account_user.test_accountuser
  terraform import -var-file=/path/account_user_cred.tfvars aviatrix_account_user.test_accountuser username1
  terraform plan -var-file=/path/account_user_cred.tfvars // not -detailed-exitcode due to sensitive password diff
  terraform show

  terraform destroy -var-file=/path/account_user_cred.tfvars -auto-approve
```

* currently working on adding import
