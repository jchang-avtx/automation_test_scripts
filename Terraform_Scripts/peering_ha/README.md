Description
-----------
  Terraform configuration files to build encrypteed peering between Aviatrix gateways in HA mode.

Pre-Requisites
--------------
    * Aviatrix controller login access
    * Aviatrix gateways already created by controller with HA enabled
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

Aviatrix Peering Topology
-------------------------
          gateway_name1 <------- primary ipsec tunnel -----> gateway_name2
     gateway_name1-hagw <------- backup  ipsec tunnel -----> gateway_name2-hagw

How to debug peering connection
-------------------------------
    Currently working on 

For more information you can visit our Aviatrix FAQs
----------------------------------------------------
Aviatrix FAQs [here](http://docs.aviatrix.com/HowTos/FAQ.html).

Encrypted Peering FAQs [here](http://docs.aviatrix.com/HowTos/peering_faq.html).

Aviatrix Overview
-----------------
Aviatrix Overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).

