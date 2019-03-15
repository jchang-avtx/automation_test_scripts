## Test case: Create/Update empty firewall_tag's cir_tag_name
## Should fail due to empty cidr_tag_names being invalid

## Input Aviatrix Controller login credentials here
aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

aviatrix_firewall_tag_name = "fw-tag-name"

cidr_list_tag_name = ["", "", "", "", "", "", "", ""] ## change was made here
cidr_list_cidr = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16", "10.13.0.0/16", "10.14.0.0/16", "10.15.0.0/16", "10.16.0.0/16", "10.17.0.0/16"]
