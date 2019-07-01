## aviatrix_account (GCloud)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/gcloud_account_cred.tfvars -auto-approve
  terraform plan -var-file=/path/gcloud_account_cred.tfvars -detailed-exitcode
  terraform show

  // gcloud_credentials_filepath does not support importing
  // terraform state rm aviatrix_account.tempacc_gcp
  // terraform import -var-file=/path/gcloud_account_cred.tfvars aviatrix_account.tempacc_gcp GCPAccess
  // terraform plan -var-file=/path/gcloud_account_cred.tfvars -detailed-exitcode
  // terraform show

  terraform apply -var-file=switchProj.tfvars -auto-approve
  terraform show

  terraform destroy -var-file=switchProj.tfvars -auto-approve
```
