Description
-----------
AWS VPCs and linux were prebuilt

terraform plan -var-file=/home/ubuntu/52.53.113.44.secret.tfvars -var account_name="EdselAWS"

terrafrom apply -auto-approve -var-file=/home/ubuntu/52.53.113.44.secret.tfvars -var account_name="EdselAWS"

terraform destroy -force -var-file=/home/ubuntu/52.53.113.44.secret.tfvars -var account_name="EdselAWS" -target=module.spoke_ca_central-1
terraform destroy -force -var-file=/home/ubuntu/52.53.113.44.secret.tfvars -var account_name="EdselAWS" -target module.shared_services_vpc
terraform destroy -force -var-file=/home/ubuntu/52.53.113.44.secret.tfvars -var account_name="EdselAWS" -target=module.transit_vpc
terraform destroy -force -var-file=/home/ubuntu/52.53.113.44.secret.tfvars -var account_name="EdselAWS"

For more information you can visit this link: http://docs.aviatrix.com/HowTos/transitvpc_workflow.html


