## Test case 3: disable local route propagation

## TGW-related
connected_domains_list1   = ["Default_Domain", "Shared_Service_Domain", "SDN1"]
connected_domains_list2   = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
connected_domains_list3   = ["Aviatrix_Edge_Domain", "Default_Domain"]
connected_domains_list4   = ["Aviatrix_Edge_Domain"]

security_domain_name_list = ["SDN1", "SDN2"]

## vpc-attachment-related
tgw_sec_domain            = "SDN2"

customized_routes = "10.10.0.0/16,10.12.0.0/16"
disable_local_route_propagation = true
