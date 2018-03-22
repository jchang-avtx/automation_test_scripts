Description
-----------
  Terraform configuration files to attached Aviatrix gateway (NAT enabled) to FQDN filter. 

Pre-Requisites
--------------
    * Aviatrix controller login access
    * Aviatrix gateways already created by controller with NAT enabled
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

How to debug FQDN filter
------------------------
    Currently working on 

For more information you can visit our Aviatrix FAQs
----------------------------------------------------
Aviatrix FAQs [here](http://docs.aviatrix.com/HowTos/FAQ.html).

Learn more about FQDN Whitelist [here](http://docs.aviatrix.com/HowTos/FQDN_Whitelists_Ref_Design.html?highlight=fqdn).

Aviatrix Overview
-----------------
Aviatrix Overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).

