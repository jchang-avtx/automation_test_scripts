## aviatrix_gateway (VPN LDAP, Duo)

### Test cases
**Note:** For AWS and AWS GovCloud VPN gateways
- update Duo Integration key
- update Duo Secret Key
- update Duo API Host name
- update Duo Push Mode
- update LDAP server
- update LDAP Bind DN
- update LDAP password
- update LDAP Base DN
- update LDAP Username Attribute

---

### Usage
```
  // DO NOT COMMIT SECRET KEYS/ TOKENS INTO GIT. Credentials committed here are only test-values, not real
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show


  terraform state rm aviatrix_gateway.aws_ldap_duo_gw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.aws_ldap_duo_gw aws-ldap-duo-gw
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
