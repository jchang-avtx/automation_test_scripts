## aviatrix_vpn_user_accelerator

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vpn_user_accelerator.test_vpn_user_accel
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vpn_user_accelerator.test_vpn_user_accel elb-for-vpn-user-accel
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
