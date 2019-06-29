## aviatrix_account_user

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/account_user_cred.tfvars -auto-approve
  terraform plan -detailed-exitcode
  terraform show

  terraform state rm aviatrix_account_user.test_accountuser
  terraform import aviatrix_account_user.test_accountuser username1
  terraform plan // not -detailed-exitcode due to known issue with diff from import. A simple apply fixes the problem
  terraform show

  terraform destroy -auto-approve
```

* currently working on adding import 
