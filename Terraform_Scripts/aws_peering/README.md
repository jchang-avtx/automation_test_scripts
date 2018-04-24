Description
-----------
  Terraform configuration files to build aws peering between two vpcs

Pre-Requisites
--------------
    * Aviatrix controller login access
    * Aviatrix access account(s) created in controller for the aws vpcs
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

AWS Peering Topology
-------------------------
          vpc1 <------- internal AWS network infrastructure -----> vpc2

How to debug peering connection
-------------------------------
    Currently working on 

For more information you can visit our Aviatrix FAQs
----------------------------------------------------
Aviatrix FAQs [here](http://docs.aviatrix.com/HowTos/FAQ.html).

Peering FAQs [here](http://docs.aviatrix.com/HowTos/peering_faq.html).

Aviatrix Overview
-----------------
Aviatrix Overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).

