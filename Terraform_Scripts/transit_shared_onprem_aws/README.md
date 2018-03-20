Description
-----------
Terraform configuration files to deploy non-HA transit network, shared services and simulated OnPrem network.

What is Transit Network
-----------------------
   Transit Network Workflow [here](http://docs.aviatrix.com/HowTos/transitvpc_workflow.html).

Pre-Requisites
--------------
    * Active AWS account and credentials
    * Aviatrix controller with username/password access
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

Default configuration
---------------------
    1 - Transit Gateway
    1 - Spoke Gateway  + Linux VM
    1 - Shared Gateway + Linux VM
    1 - OnPrem Gateway + Linux VM

Check transit network via End-to-End test
-----------------------------------------
    1. After successful terraform run, it will display output with all Linux VM private and public IPs.
    2. Do ssh to any Linux VM public IP and ping to other Linux VMs private IPs. 
       Example: 
               ssh -i mykey ubuntu@Linux_VM_Public_IP
               ping destination_Linux_VM_Private_IP
               
Notes
-----
    1. From terraform.tfvar file, user can modify [spoke_gateways = 1] in order to increase spoke gateways.
    2. For large transit network deployment, sometimes need to invoke again "terraform destroy -force" .

How to debug transit network
----------------------------
    1. Use Aviatrix controller portal to monitor and control all gateway deployments.  
       [ https://controller_elastic_ip ] where controller_elastic_ip = 13.80.130.82
    2. Check all the transit, spoke and onprem gateways and MUST be in green "UP" state.
       [ https://controller_elastic_ip/#/gateway ]
       If gateway state in "waiting", give at least 2 minutes sync between controller and gateway. 
       If gateway state in "down", go to diagnostics 
          * Troubleshoot > Diagnostics > Gateway > [gateway-name] > click Run
    3. Check all the encrypted peering in green "UP" state. [ https://controller_elastic_ip/#/peering ]
    4. Check if transit network able to see OnPrem network. Go to transitive peering page 
       and make sure each spoke has its own entry. 
           * Peering > Transitive Peering
    5. Check all VGW connectivity and status MUST be in green "UP" state. 
           * Go to Site2Cloud > Site2Cloud 
       If status is "down", use Diagnostics feature. Site2Cloud > Diagnostics
    6. To verify advertise and learned routes from BGP and VGW point of view. 
           * Go to Advance Config > BGP > click "vgw_bgp_s2c_conn"    
           * advertise routes means "all the SPOKE aviatrix gateway cidrs advertise to VGW"
           * learned routes means "all the routes aviatrix transit gateway learned from VGW" via BGP 
           * BGP means "BGP connection over IPSec tunnel" to AWS VGW
    7. For more aviatrix technical support, send email to support@aviatrix.com. 

    Our aviatrix subject matter expert is just one phone call away! 

What is Shared Services VPC
---------------------------
It is specific VPC where an aviatrix gateway been deployed and with direct connection via encrypteed tunnel to all spoke gateways.  It is meant tobe accessible to all users for the entire transit network topology. Shared services like (i.e. database, web, jenkins, puppet, chef, saltstack, etc.) are consolidated for network simplicity.

What is simulated OnPrem Network
--------------------------------
It is Aviatrix gateway connected to VGW using static IPSec tunnel. Aviatrix feature called "Site2Cloud" where user is able
to establish an IPSec tunnel to a third party device in this case AWS VGW.   
  
For more information you can visit our Aviatrix FAQs
----------------------------------------------------
   Aviatrix FAQs [here](http://docs.aviatrix.com/HowTos/FAQ.html).

Aviatrix Overview
-----------------
   Aviatrix Overview [here](http://docs.aviatrix.com/StartUpGuides/aviatrix_overview.html).
