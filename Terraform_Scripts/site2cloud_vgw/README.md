Description
-----------
    Terraform configuration files to site2cloud connection between Aviatrix Gateway and AWS VGW.

       * Site2Cloud FAQs [here](http://docs.aviatrix.com/HowTos/site2cloud_faq.html).

Pre-Requisites
--------------
    * Active AWS account and credentials
    * Up and running Aviatrix controller and credentials
    * Update file named "terraform.tfvars" to input all credentials

Launch new Controller with CloudFormation Template
--------------------------------------------------
    New Aviatrix Controller guide [here](http://docs.aviatrix.com/StartUpGuides/aviatrix-cloud-controller-startup-guide.html#launch-the-controller-with-cloudformation-template).

How to run terraform
--------------------
    * terraform plan                = to check and review all parameters
    * terraform apply auto-approve  = to kickoff the run
    * terraform destroy -force      = to cleanup everything 

Default configuration
---------------------
    1 - OnPrem Gateway

How to debug site2cloud connection
----------------------------------
    Currently working on .....

  
For more information you can visit our Aviatrix FAQs
----------------------------------------------------
    Avitrix FAQs [here](http://docs.aviatrix.com/HowTos/FAQ.html).

Aviatrix Overview
-----------------
    Aviatrix Overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).

