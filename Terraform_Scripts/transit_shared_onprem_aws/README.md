Description
-----------
Terraform configuration files to deploy transit network, shared services and simulated OnPrem network.

What is Transit Network
-----------------------
http://docs.aviatrix.com/HowTos/transitvpc_workflow.html

What is Shared Services VPC
---------------------------
It is specific VPC where an aviatrix gateway been deployed and with direct connection via encrypteed tunnel to all spoke gateways.  It is meant tobe accessible to all users for the entire transit network topology. Shared services like (i.e. database, web, jenkins, puppet, chef, saltstack, etc.) are consolidated for network simplicity.

What is simulated OnPrem Network
--------------------------------
It is Aviatrix gateway connected to VGW using static IPSec tunnel. Aviatrix feature called "Site2Cloud" where user is able
to establish an IPSec tunnel to a third party device in this case AWS VGW.   

Pre-Requisites
--------------
    * AWS Account and credentials
    # Aviatrix Controller credentials

Default configuration
---------------------
    1 - Transit Gateway
    1 - Spoke Gateway  + Linux VM
    1 - Shared Gateway + Linux VM
    1 - OnPrem Gateway + Linux VM

Notes:
1. To advertise the onprem network from site2cloud, user needs to manually add the onprem CIDR
   from AWS Console > VGW Connection > Static Routes tab.

2. Edit spoke_gateways =<N> under terraform.tfvar file in order to increase spoke gateways.

For more information you can visit this link: http://docs.aviatrix.com/HowTos/transitvpc_workflow.html


