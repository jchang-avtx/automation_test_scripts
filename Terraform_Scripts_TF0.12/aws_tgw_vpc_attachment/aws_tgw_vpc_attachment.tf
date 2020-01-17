resource "aviatrix_aws_tgw" "test_aws_tgw2" {
  tgw_name                = "testAWSTGW2"
  account_name            = "AWSAccess"
  region                  = "eu-central-1"
  aws_side_as_number      = "65412"

  security_domains {
    security_domain_name  = "Aviatrix_Edge_Domain"
    connected_domains     = ["Default_Domain", "Shared_Service_Domain", "SDN1"]
  }
  security_domains {
    security_domain_name  = "Default_Domain"
    connected_domains     = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name  = "Shared_Service_Domain"
    connected_domains     = ["Aviatrix_Edge_Domain", "Default_Domain"]
  }
  security_domains {
    security_domain_name  = "SDN1"
    connected_domains     = ["Aviatrix_Edge_Domain"]
  }
  security_domains {
    security_domain_name  = "SDN2"
  }

  manage_vpc_attachment   = false
}

# Manage attaching or detaching VPCs to AWS TGW
resource "aviatrix_aws_tgw_vpc_attachment" "tgw_vpc_attach_test" {
  tgw_name              = aviatrix_aws_tgw.test_aws_tgw2.tgw_name
  region                = aviatrix_aws_tgw.test_aws_tgw2.region
  security_domain_name  = var.tgw_sec_domain
  vpc_account_name      = aviatrix_aws_tgw.test_aws_tgw2.account_name
  vpc_id                = "vpc-00119a5b202c81d97"

  customized_routes                 = var.customized_routes
  disable_local_route_propagation   = var.disable_local_route_propagation

  subnets                         = var.adv_subnets
  route_tables                    = var.adv_rtb
  customized_route_advertisement  = var.adv_custom_route_advertisement
}

output "tgw_vpc_attach_test_id" {
  value = aviatrix_aws_tgw_vpc_attachment.tgw_vpc_attach_test.id
}
