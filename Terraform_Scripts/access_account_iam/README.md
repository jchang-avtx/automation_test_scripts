Description
-----------
Aviatrix access account with IAM ROLE enabled.

terraform init
terraform validate -var-file=/home/ubuntu/test_account.tfvars
terraform plan -var-file=/home/ubuntu/test_account.tfvars
terraform apply -auto-approve -var-file=/home/ubuntu/test_account.tfvars
terraform destroy -force -var-file=/home/ubuntu/test_account.tfvars
