Description
-----------
  1. Terraform configuration files to attached Aviatrix gateway (NAT enabled) to FQDN filter. 
  2. It assumed aviatrix gateway is ready from designated controller.

  FYI: Implementation was based on Aviatrix UserConnect-3.3.403 version.



terraform validate -var-file=/home/ubuntu/52.52.3.186_regression.secret.tfvars
terraform plan -var-file=/home/ubuntu/52.52.3.186_regression.secret.tfvars
terraform apply -auto-approve -var-file=/home/ubuntu/52.52.3.186_regression.secret.tfvars
terraform destroy -force -var-file=/home/ubuntu/52.52.3.186_regression.secret.tfvars

For more information you can visit our Aviatrix FAQs
----------------------------------------------------
Learn more about FQDN Whitelist [here](http://docs.aviatrix.com/HowTos/FQDN_Whitelists_Ref_Design.html?highlight=fqdn).

