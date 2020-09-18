## aviatrix_gateway (VPN Okta)

### Test cases
**Note:** For AWS and AWS GovCloud VPN gateways
- update Okta URL
- update Okta token
- update Okta username suffix

---

### Usage
```
  // DO NOT COMMIT SECRET KEYS/ TOKENS INTO GIT. Credentials committed here are only test-values, not real
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_gateway.aws_okta_gw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.aws_okta_gw aws-okta-gw
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateURL.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateToken.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateUsernameSuffix.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
