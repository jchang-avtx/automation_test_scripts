## aviatrix_trans_peer

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_trans_peer.transitive-peering
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_trans_peer.transitive-peering NAT-gw1~NAT-gw2~55.55.55.0/24
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
