## aviatrix_arm_peer

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_arm_peer.test_armpeer
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_arm_peer.test_armpeer TransitVNet:TransitRG~SpokeVNet:SpokeRG
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
