## aviatrix_aws_peer

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/aws_peer_cred.tfvars -auto-approve
  terraform plan -detailed-exitcode
  terraform show

  terraform state rm aviatrix_aws_peer.test_awspeer
  terraform import aviatrix_aws_peer.test_awspeer vpc-0cbdc7571b2fd28bf~vpc-ba3c12dd
  terraform plan -detailed-exitcode
  terraform show

  // terraform apply -var-file=/path/aws_peer_cred.tfvars -auto-approve // no changes made. fixing rtb diffs

  terraform destroy -var-file=/path/aws_peer_cred.tfvars -auto-approve
```

* currently working on adding import
