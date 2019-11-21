## aviatrix_aws_tgw_directconnect

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_aws_tgw_directconnect.aws_tgw_dc
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_aws_tgw_directconnect.aws_tgw_dc testAWSTGW2~629dddaa-cc3d-41da-b54e-83bb43b6934b
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updatePrefix.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
