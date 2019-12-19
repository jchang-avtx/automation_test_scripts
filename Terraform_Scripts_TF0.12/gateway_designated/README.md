## aviatrix_gateway (Designated Gateway + DNAT) (AWS + ARM)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_gateway.design_gw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.design_gw design-gw
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_gateway.design_arm_gw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.design_arm_gw design-arm-gw
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateCIDRs.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateDNAT.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve

```
