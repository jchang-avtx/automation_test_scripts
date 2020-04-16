# Aviatrix TGW Inter-region Peering (AWS)

---

### Infrastructure
- 2 AWS TGWs in different regions
- Peering between the two

### Test case
- verify AWS TGW built
- verify AWS TGW Inter-region peering works
- **NOTE:** will update and add full TGW build after- simple test for now


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_aws_tgw_peering.tgw_peering
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_aws_tgw_peering.tgw_peering id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
