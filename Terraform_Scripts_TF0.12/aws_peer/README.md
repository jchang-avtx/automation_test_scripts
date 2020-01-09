## aviatrix_aws_peer

* must export AWS provider credentials in script
---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_aws_peer.test_awspeer
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_aws_peer.test_awspeer vpc-abc123~vpc-def456
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
