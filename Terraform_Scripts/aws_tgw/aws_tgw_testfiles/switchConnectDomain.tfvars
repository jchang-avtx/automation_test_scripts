## Test case 1: Update Connected Doamins

##############################################
## VALID INPUT
##############################################
aviatrix_tgw_name = "testAWSTGW"
aviatrix_cloud_account_name = "devops"
aviatrix_tgw_region = "us-east-1"
aws_bgp_asn = "65412"

connected_domains_list1 = ["Default_Domain", "Shared_Service_Domain", "SDN1"]
connected_domains_list2 = ["Aviatrix_Edge_Domain", "Shared_Service_Domain", "SDN1"] # << EDITED CONNETED DOMAIN NAME
connected_domains_list3 = ["Aviatrix_Edge_Domain", "Default_Domain"]
connected_domains_list4 = ["Aviatrix_Edge_Domain", "Default_Domain"] # << EDITED CONNECTED DOMAIN NAME

security_domain_name_list = ["SDN1", "SDN2"]
aws_region = ["us-east-1", "us-east-1", "us-east-1", "us-east-1"]
aviatrix_cloud_account_name_list = ["devops1", "devops1", "devops2", "devops"]
aws_vpc_id = ["vpc-abc", "vpc-def", "vpc-123", "vpc-456"]
