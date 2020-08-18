## aviatrix_saml_endpoint

### Infrastructure
- 2 SAML endpoints
- 2 SAML login endpoints

### Test case
- verify SAML endpoints
- verify SAML login endpoints
- update `idp_metadata` for text SAML endpoint
- update `access_set_by` for login endpoint
- update `rbac_groups` for login endpoint

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_saml_endpoint.text_saml_endpoint
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_saml_endpoint.text_saml_endpoint text_saml_endpoint
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_saml_endpoint.custom_saml_endpoint
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_saml_endpoint.custom_saml_endpoint custom_saml_endpoint
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_saml_endpoint.text_login_endpoint
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_saml_endpoint.text_login_endpoint text_login_endpoint
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_saml_endpoint.custom_login_endpoint
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_saml_endpoint.custom_login_endpoint custom_login_endpoint
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=updateIDPmetadata.tfvars -auto-approve
  terraform plan -var-file=updateIDPmetadata.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=updateEntityID.tfvars -auto-approve
  terraform plan -var-file=updateEntityID.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=updateAccess.tfvars -auto-approve
  terraform plan -var-file=updateAccess.tfvars -detailed-exitcode
  terraform

  terraform apply -var-file=updateRBAC.tfvars -auto-approve
  terraform plan -var-file=updateRBAC.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
