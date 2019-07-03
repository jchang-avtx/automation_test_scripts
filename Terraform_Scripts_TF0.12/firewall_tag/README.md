## aviatrix_firewall_tag

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_firewall_tag.fw_tag_test
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firewall_tag.fw_tag_test fw-tag-name
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateCIDR.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateCIDRTagName.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
