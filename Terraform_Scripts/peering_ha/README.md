Description
-----------
  Terraform configuration files to build encrypteed peering between Aviatrix gateways in HA mode.

Pre-Requisites
--------------
    * Aviatrix controller with login credentials
    * Pre-configured AWS VPCs

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

For more information you can visit our Aviatrix FAQs
----------------------------------------------------
Encrypted Peering FAQs [here](http://docs.aviatrix.com/HowTos/peering_faq.html).
