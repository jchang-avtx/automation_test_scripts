Description
-----------
  Terraform configuration files to create aviatrix datacenter extension gateways from Virtual Appliance CloudN

  CloudN guide [here](http://docs.aviatrix.com/StartUpGuides/CloudN-Startup-Guide.html).

Pre-Requisites
--------------
    * Active AWS account and credentials
    * Up and running Virtual Appliance CloudN and credentials
    * CloudN number of VPC/vNets configured to 2
    * Update file named "terraform.tfvars" to input all credentials

How to run terraform
--------------------
    * terraform plan                = to check and review all parameters
    * terraform apply auto-approve  = to kickoff the run
    * terraform destroy -force      = to cleanup everything 

How to debug datacenter extension
---------------------------------
    Currently working on .....

  
For more information you can visit our Aviatrix FAQs
----------------------------------------------------
   Aviatrix FAQs [here](http://docs.aviatrix.com/HowTos/FAQ.html).

Aviatrix Overview
-----------------
   Aviatrix product overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).

