# Aviatrix VPN Profiles + Users Management
---

### Infrastructure
- VPC
- VPN Gateway
- 2 VPN users (1 manage_user_attachment true, 1 false)
- 3 VPN profiles (2 attached to VPN user 1 with, 1 attached to VPN user 2)

### Test case
- verify VPN attachment management options


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
