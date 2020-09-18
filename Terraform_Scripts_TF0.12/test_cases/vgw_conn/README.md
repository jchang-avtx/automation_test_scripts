## aviatrix_vgw_conn

### Test cases
**Note:** Advertising transit CIDRs have been moved to be managed to transit_gateway from vgw_conn
- toggle CIDR advertisement and specify specific CIDRs
- AWS, Azure, GCP cloud test cases 

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_vgw_conn.test_vgw_conn
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_vgw_conn.test_vgw_conn test_connection_tgw_vgw~vpc-0c32b9c3a144789ef
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=toggleCIDRAdvert.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
