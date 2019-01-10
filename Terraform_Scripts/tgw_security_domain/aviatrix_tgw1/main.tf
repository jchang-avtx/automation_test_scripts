resource "aviatrix_aws_tgw" "us-east-tgw1" {
  count                             = "${var.max_tgw}"
  region                            = "${var.mod_regions[0]}"
  tgw_name                          = "tgw-${var.mod_regions[0]}-${count.index}"
  account_name                      = "${var.mod_act_list[0]}"
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


## add vpc creation module 


resource "aviatrix_aws_tgw" "us-east-tgw2" {
  count                             = "${var.max_tgw}"
  region                            = "${var.mod_regions[1]}"
  tgw_name                          = "tgw-${var.mod_regions[1]}-${count.index}"
  account_name                      = "${var.mod_act_list[1]}"
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

