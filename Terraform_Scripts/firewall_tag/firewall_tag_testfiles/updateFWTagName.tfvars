## Test case: Update firewall_tag's tag name
## Should fail due to not supporting updating fw_tag_name

## Input Aviatrix Controller login credentials here
aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

aviatrix_firewall_tag_name = "fw-tag-name-UPDATED" ## Updated tag name

cidr_list_tag_name = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7", "tag8"]
cidr_list_cidr = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16", "10.13.0.0/16", "10.14.0.0/16", "10.15.0.0/16", "10.16.0.0/16", "10.17.0.0/16"]
