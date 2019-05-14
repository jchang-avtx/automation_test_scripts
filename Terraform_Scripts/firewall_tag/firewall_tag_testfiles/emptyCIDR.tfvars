## Test case: create/ update with empty CIDR
## should fail because CIDR cannot be empty

##############################################

aviatrix_firewall_tag_name = "fw-tag-name"

cidr_list_tag_name = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7", "tag8"]
cidr_list_cidr = ["", "", "", "", "", "", "", ""] # empty CIDRs
