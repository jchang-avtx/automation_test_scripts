## aviatrix_spoke_vpc

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_vpc.test_spoke_vpc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_vpc.test_spoke_vpc spoke-gw-01
  terraform plan -var-file=/path/provider_cred.tfvars // no -detailed-exitcode due to tag diffs
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateTransitGW.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateGWSize.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateHAGWSize.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
