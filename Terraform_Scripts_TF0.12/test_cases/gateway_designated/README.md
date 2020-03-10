## aviatrix_gateway (Designated Gateway + DNAT) (AWS + ARM)

---
### Test cases
- Designated gateway (AWS)
- SNAT policies (AWS)
- DNAT policies (AWS)
- SNAT policies (Azure)
- DNAT policies (Azure)
- Mantis (13505) - DNAT resource creation fails due to existing SNAT policy (incorrect arg reference)


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
