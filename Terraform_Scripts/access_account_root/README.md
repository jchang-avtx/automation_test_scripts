Description
-----------
Aviatrix access account using root credentials.  IAM ROLE=DISABLED

terraform init
terraform validate -var-file=/home/ubuntu/test_account_root.tfvars
terraform plan -var-file=/home/ubuntu/test_account_root.tfvars
terraform apply -auto-approve -var-file=/home/ubuntu/test_account_root.tfvars
terraform destroy -force -var-file=/home/ubuntu/test_account_root.tfvars
