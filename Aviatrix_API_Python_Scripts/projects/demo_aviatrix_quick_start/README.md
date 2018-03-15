Project: Aviatrix Quick Start
================================================================================


Description:
==================================================

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