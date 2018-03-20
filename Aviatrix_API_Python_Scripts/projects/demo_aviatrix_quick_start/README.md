Project: Aviatrix Quick Start
================================================================================


Description:
================================================================================

* This project does the following...
    + Create Aviatrix Cloud Controller EC2 instance in a specified region
    + Create a new VPC/Public Subnet
    + Create Aviatrix IAM Roles if not there
    + Create AWS Key-Pair for Aviatrix Cloud Controller EC2 instance (configurable to use existing Key-Pair)
    + Finish Aviatrix Initial-Setup and Onboarding processes
    
* To create Aviatrix Cloud Controller...

    $ python create_aviatrix_cloud_controller.py

* To delete Aviatrix Cloud Controller... 

    $ python delete_aviatrix_cloud_controller.py

* Before deleting the Aviatrix Controller, please make sure you have deleted all Cloud Accounts in the controller.





More Design Detail:
================================================================================

* log indentation
    + The variable "log_indentation" is just a string consists with white-space-character to indent logger 
    + By default, calling funA() from main.py(layer 0) no need to pass "log_indentation"
    + In side of funA() calling funB(log_indentation=log_indentation+"    "). Passing funA's current indentation plus 4 
    more white-space characters to funB to make funB to be nested inside of funA

* Current design is to make AWS/Aviatrix functions "flat" (no class or too many layers) to have a easier structure for users to understand

* The workflow to create Aviatrix EC2 Role...
    1) to be continued
    2) to be continued
    3) to be continued

    
* The workflow to create Aviatrix APP Role...
    1) to be continued
    2) to be continued
    3) to be continued
   
    
* The workflow to create Aviatrix VPC + Public Subnet...
    1) to be continued
    2) to be continued
    3) to be continued
   
    
* The workflow to create Aviatrix EC2 Instance...
    1) to be continued
    2) to be continued
    3) to be continued
   
    
  