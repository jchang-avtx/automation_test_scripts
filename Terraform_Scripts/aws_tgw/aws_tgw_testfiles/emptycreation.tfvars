# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis: id=8428 for issues with refresh/ update
## This file is also used to test Update/ refresh test case;; See sections for Valid Input

## You must input valid credentials here
aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT
##############################################
# aviatrix_tgw_name = "testAWSTGW"
# aviatrix_cloud_account_name = "devops"
# aviatrix_tgw_region = "us-east-1"
# aws_bgp_asn = "65412"
#
# connected_domains_list1 = ["Default_Domain", "Shared_Service_Domain", "SDN1"]
# connected_domains_list2 = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
# connected_domains_list3 = ["Aviatrix_Edge_Domain", "Default_Domain"]
# connected_domains_list4 = ["Aviatrix_Edge_Domain"]
#
# security_domain_name_list = ["SDN1", "SDN2"]
# aws_region = ["us-east-1", "us-east-1", "us-east-1", "us-east-1"]
# aviatrix_cloud_account_name_list = ["devops1", "devops1", "devops2", "devops"]
# aws_vpc_id = ["vpc-abc", "vpc-def", "vpc-123", "vpc-456"]

##############################################
## EMPTY/INVALID INPUT
##############################################
aviatrix_tgw_name = ""
aviatrix_cloud_account_name = ""
# aviatrix_cloud_account_name = "invalidAccountName"
aviatrix_tgw_region = ""
# aviatrix_tgw_region = "invalidRegion"
aws_bgp_asn = ""
# aws_bgp_asn = "notInteger"

connected_domains_list1 = ["", "", ""]
connected_domains_list2 = ["", ""]
connected_domains_list3 = ["", ""]
connected_domains_list4 = [""]
# connected_domains_list1 = ["notaRealDomain"] # invalid; only need to test one variable because it is under the same parameter

security_domain_name_list = ["", ""] # the three: Aviatrix_Edge_Domain, Default_Domain, Shared_Service_Domain that are not listed under this variable and tested because they are default
aws_region = ["", "", "", ""]
# aws_region = ["unreal", "fake", "love", "invalid"] # invalid regions
aviatrix_cloud_account_name_list = ["", "", "", ""]
# aviatrix_cloud_account_name_list = ["invalidAccountName", "again", "repeat", "ditto"]
aws_vpc_id = ["", "", "", ""]
# aws_vpc_id = ["notrealVPC", "invalidVPC", "fakeVPC", "fakeLove"] # invalid VPC ids
