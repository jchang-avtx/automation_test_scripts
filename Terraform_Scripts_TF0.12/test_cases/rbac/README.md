# Aviatrix RBAC (Role-based Access Control)
---

### Infrastructure
- account_user
- access_account
- RBAC group
- RBAC group user attachment
- RBAC group account attachment
- RBAC group permission attachment

### Test case
- verify RBAC workflow


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_rbac_group.rbac_tf_export_group
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_rbac_group.rbac_tf_export_group id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_rbac_group_access_account_attachment.rbac_tf_export_group_acc_att
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_rbac_group_access_account_attachment.rbac_tf_export_group_acc_att id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_rbac_group_permission_attachment.rbac_tf_export_group_permission_att
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_rbac_group_permission_attachment.rbac_tf_export_group_permission_att id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_rbac_group_user_attachment.rbac_tf_export_group_user_att
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_rbac_group_user_attachment.rbac_tf_export_group_user_att id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
