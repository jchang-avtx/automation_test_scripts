## aviatrix_gateway (vpn LDAP, Duo)

---

### Usage
```
  // DO NOT COMMIT SECRET KEYS/ TOKENS INTO GIT. Credentials committed here are only test-values, not real
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show


  terraform state rm aviatrix_gateway.testGW4
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.testGW4 testGW4
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show


  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=duoUpdateIntKey.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=duoUpdateSecretKey.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=duoUpdateAPIHost.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=duoUpdatePushMode.tfvars \
                  -auto-approve
  terraform show


  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=ldapUpdateServer.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=ldapUpdateBindDN.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=ldapUpdatePassword.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=ldapUpdateBaseDN.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=ldapUpdateUsername.tfvars \
                  -auto-approve
  terraform show


  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
