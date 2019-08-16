## aviatrix_saml_endpoint

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

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
