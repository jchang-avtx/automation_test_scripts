## aviatrix_azure_peer

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_azure_peer.azure_test_peer
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_azure_peer.azure_test_peer Vnet1:RG1~Vnet2:RG2
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
