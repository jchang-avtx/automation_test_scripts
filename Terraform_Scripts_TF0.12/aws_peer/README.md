## aviatrix_aws_peer

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_aws_peer.test_awspeer
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_aws_peer.test_awspeer vpc-0cbdc7571b2fd28bf~vpc-ba3c12dd
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  // terraform apply -var-file=/path/provider_cred.tfvars -auto-approve // no changes made. fixing rtb diffs

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
