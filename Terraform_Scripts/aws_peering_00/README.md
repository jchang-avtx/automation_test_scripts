# terraform regression for aws peering via aviatrix controller

terraform plan -var-file=/home/ubuntu/54.177.55.54.secret.tfvars
terraform apply -auto-approve -var-file=/home/ubuntu/54.177.55.54.secret.tfvars
terraform destroy -force -var-file=/home/ubuntu/54.177.55.54.secret.tfvars
