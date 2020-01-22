## aviatrix_gateway, aviatrix_spoke_gateway (S/DNAT)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.sdnat_spoke_aws_gw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.sdnat_spoke_aws_gw sdnat-spoke-aws-gw
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.sdnat_spoke_arm_gw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.sdnat_spoke_arm_gw sdnat-spoke-arm-gw
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateSNAT.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateDNAT.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
