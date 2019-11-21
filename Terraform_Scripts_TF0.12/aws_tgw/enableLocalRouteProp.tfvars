## Test case 4: enable local route propogation

connected_domains_list1   = ["Default_Domain", "Shared_Service_Domain", "SDN1"]
connected_domains_list2   = ["Aviatrix_Edge_Domain", "Shared_Service_Domain", "SDN1"] # << EDITED CONNECTED DOMAIN NAME
connected_domains_list3   = ["Aviatrix_Edge_Domain", "Default_Domain"]
connected_domains_list4   = ["Aviatrix_Edge_Domain", "Default_Domain"] # << EDITED CONNECTED DOMAIN NAME

security_domain_name_list = ["SDN1", "SDN2"]
aws_vpc_id                = ["vpc-0aefc4bd4976a8bc6", "vpc-08e3715762bda00fc", "vpc-0b730945d29ccfa9e"] # << EDITED 1st and 2nd VPC

custom_routes_list              = "10.8.0.0/16" # << EDITED ROUTES
disable_local_route_propagation = false # << enable local route prop
