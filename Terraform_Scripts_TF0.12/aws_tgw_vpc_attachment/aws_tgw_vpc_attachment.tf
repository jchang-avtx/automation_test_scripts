resource "aviatrix_aws_tgw" "test_aws_tgw2" {
  tgw_name                = "testAWSTGW2"
  account_name            = "AWSAccess"
  region                  = "eu-central-1"
  aws_side_as_number      = "65412"

  security_domains {
    security_domain_name  = "Aviatrix_Edge_Domain"
    connected_domains     = var.connected_domains_list1
  }
  security_domains {
    security_domain_name  = "Default_Domain"
    connected_domains     = var.connected_domains_list2
  }
  security_domains {
    security_domain_name  = "Shared_Service_Domain"
    connected_domains     = var.connected_domains_list3
  }
  security_domains {
    security_domain_name  = var.security_domain_name_list[0]
    connected_domains     = var.connected_domains_list4
  }
  security_domains {
    security_domain_name  = var.security_domain_name_list[1]
  }

  manage_vpc_attachment   = false
}

# Manage attaching or detaching VPCs to AWS TGW
resource "aviatrix_aws_tgw_vpc_attachment" "tgw_vpc_attach_test" {
  tgw_name              = "testAWSTGW2"
  region                = aviatrix_aws_tgw.test_aws_tgw2.region
  security_domain_name  = var.tgw_sec_domain
  vpc_account_name      = aviatrix_aws_tgw.test_aws_tgw2.account_name
  vpc_id                = "vpc-00119a5b202c81d97"
  customized_routes     = var.customized_routes
  disable_local_route_propagation = var.disable_local_route_propagation
}

output "tgw_vpc_attach_test_id" {
  value = aviatrix_aws_tgw_vpc_attachment.tgw_vpc_attach_test.id
}
