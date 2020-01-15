## aviatrix_geo_vpn

---
### Prerequisite
* must have set up and registered a domain on Route53

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_geo_vpn.test_geo_vpn
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_geo_vpn.test_geo_vpn `terraform output test_geo_vpn_id`
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateELB.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
