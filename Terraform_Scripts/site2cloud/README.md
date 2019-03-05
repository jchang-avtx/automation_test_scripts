# Description
-----------
##### Terraform configuration files to create Site2Cloud resource and manage Aviatrix Site2Cloud connection

* In order to test backup parameters:
  * must comment out the **'depends_on'** parameter in the S2C resource
  * must comment out the 2 gateway resources
  * must uncomment out the respective backup parameters in the **site2cloud.tf, terraform.tfvars, vars.tf**
  * manually create 2 Aviatrix gateways to emulate the environment; this is because backup-gateway names cannot be specified on creation, and therefore automation does not work
    * consequently, must modify the S2C values accordingly
