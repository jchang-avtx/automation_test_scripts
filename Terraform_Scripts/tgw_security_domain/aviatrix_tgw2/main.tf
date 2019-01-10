resource "aviatrix_aws_tgw" "region1" {
  count                             = "${var.mod_tgw_per_region["us-west-1"]}"
  region                            = "us-west-1"
  tgw_name                          = "tgw-us-west-1-${count.index}"
  account_name                      = "Temporary-AWS-account"
  aws_side_as_number                = "${count.index + 64512}"
  attached_aviatrix_transit_gateway = []
  security_domains = [
  {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = ["Default_Domain", "Shared_Service_Domain"]          
  },
  {
    security_domain_name = "Default_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]    
    attached_vpc         = []      
  },
  {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Default_Domain"]
    attached_vpc         = []          
  },
  ]
}
resource "aviatrix_aws_tgw" "region2" {
  count                             = "${var.mod_tgw_per_region["us-west-2"]}"
  region                            = "us-west-2"
  tgw_name                          = "tgw-us-west-2-${count.index}"
  account_name                      = "Temporary-AWS-account"
  aws_side_as_number                = "${count.index + 64512}"
  attached_aviatrix_transit_gateway = []
  security_domains = [
  {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = ["Default_Domain", "Shared_Service_Domain"]          
  },
  {
    security_domain_name = "Default_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]    
    attached_vpc         = []      
  },
  {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Default_Domain"]
    attached_vpc         = []          
  },
  ]
}


