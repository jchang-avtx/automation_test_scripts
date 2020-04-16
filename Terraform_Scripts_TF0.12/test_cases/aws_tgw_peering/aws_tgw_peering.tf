resource "aviatrix_aws_tgw" "peer_tgw_1" {
  tgw_name        = "aws_tgw_peer_1"
  account_name    = "AWSAccess"
  region          = "eu-central-1"
  aws_side_as_number = 65413
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
  }
  manage_vpc_attachment                 = false
  manage_transit_gateway_attachment     = false
}

resource "aviatrix_aws_tgw" "peer_tgw_2" {
  tgw_name        = "aws_tgw_peer_2"
  account_name    = "AWSAccess"
  region          = "eu-west-1"
  aws_side_as_number = 65414
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
  }
  manage_vpc_attachment                 = false
  manage_transit_gateway_attachment     = false
}

resource "aviatrix_aws_tgw_peering" "tgw_peering"{
  tgw_name1 = aviatrix_aws_tgw.peer_tgw_2.tgw_name
  tgw_name2 = aviatrix_aws_tgw.peer_tgw_1.tgw_name
}

output "tgw_peering_id" {
  value = aviatrix_aws_tgw_peering.tgw_peering.id
}
