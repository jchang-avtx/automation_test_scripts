Description
-----------
  Terraform configuration files to create Aviatrix gateways.

Pre-Requisites
--------------
    * Aviatrix controller login access
    * AWS access key and secret key
    * AWS VPC with public subnet
    * Update file named "terraform.tfvars" to input all parameters

Launch new Controller with CloudFormation Template
--------------------------------------------------
New Aviatrix Controller guide [here](http://docs.aviatrix.com/StartUpGuides/aviatrix-cloud-controller-startup-guide.html#launch-the-controller-with-cloudformation-template).

How to run terraform
--------------------
    * terraform init                = initialize working directorty and provider plugins, done only once 
    * terraform plan                = to check and review all parameters
    * terraform apply auto-approve  = to kickoff the run
    * terraform destroy -force      = to cleanup everything 

How to debug peering connection
-------------------------------
    Currently working on 

For more information you can visit our Aviatrix FAQs
----------------------------------------------------
Aviatrix Gateway Information [here](http://docs.aviatrix.com/HowTos/gateway.html).

Aviatrix Overview
-----------------
Aviatrix Overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).

