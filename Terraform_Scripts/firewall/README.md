Description
-----------
  Terraform configuration files to create stateful firewall policy.

Pre-Requisites
--------------
    * Aviatrix controller ip/username/password for login access
    * Aviatrix gateway

Aviatrix Firewall Overview
------------------------------
Tag Based Security Policy [here](https://docs.aviatrix.com/HowTos/tag_firewall.html).

Usage
-----
Please note to separate the **firewall.tf**, **firewall_all.tf**, **firewall_icmp.tf** into different directories in order to avoid test issues with Terraform auto creating all resources listed in the .tf files
