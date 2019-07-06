## aviatrix_vpn_user

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -var-file=user_emails.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpn_user.test_vpn_user1
  terraform import -var-file=/path/provider_cred.tfvars -var-file=user_emails.tfvars aviatrix_vpn_user.test_vpn_user1 testdummy1
  terraform plan -var-file=/path/provider_cred.tfvars -var-file=user_emails.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -var-file=user_emails.tfvars -auto-approve
```
