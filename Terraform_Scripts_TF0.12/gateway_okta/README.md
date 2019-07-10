## aviatrix_gateway (vpn Okta)

---

### Usage
```
  // DO NOT COMMIT SECRET KEYS/ TOKENS INTO GIT. Tokens committed here are only test-keys, not real
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_gateway.testGW3
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.testGW3 testGW3
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
