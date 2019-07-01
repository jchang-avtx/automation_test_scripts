## aviatrix_arm_peer

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/arm_peer_cred.tfvars -auto-approve
  terraform plan -var-file=/path/arm_peer_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_arm_peer.test_armpeer
  terraform import -var-file=/path/arm_peer_cred.tfvars aviatrix_arm_peer.test_armpeer TransitVNet:TransitRG~SpokeVNet:SpokeRG
  terraform plan -var-file=/path/arm_peer_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/arm_peer_cred.tfvars -auto-approve
```

* currently working on adding import
