## Manages the AWS TGW (Orchestrator)

resource "aviatrix_transit_gateway" "test_transit_gw" {
  cloud_type                  = 1
  account_name                = "AWSAccess"
  gw_name                     = "testTransitVPCGW"
  vpc_id                      = "vpc-0b92c79340ba016ee"
  vpc_reg                     = "eu-central-1"
  gw_size                     = "t2.micro"
  subnet                      = "99.99.99.96/28"

  enable_hybrid_connection    = true
  connected_transit           = true
  enable_active_mesh          = false
}

resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name             = "vgw_conn_for_tgw_test"
  gw_name               = aviatrix_transit_gateway.test_transit_gw.gw_name
  vpc_id                = aviatrix_transit_gateway.test_transit_gw.vpc_id
  bgp_vgw_id            = "vgw-041baa40dfbf28c9a"
  bgp_vgw_account       = aviatrix_transit_gateway.test_transit_gw.account_name
  bgp_vgw_region        = aviatrix_transit_gateway.test_transit_gw.vpc_reg
  bgp_local_as_num      = "65001"
  depends_on            = ["aviatrix_transit_gateway.test_transit_gw"]
}

resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name                          = "testAWSTGW"
  account_name                      = aviatrix_transit_gateway.test_transit_gw.account_name
  region                            = aviatrix_transit_gateway.test_transit_gw.vpc_reg
  aws_side_as_number                = "65412"
  attached_aviatrix_transit_gateway = ["testTransitVPCGW"]

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = var.connected_domains_list1
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = var.connected_domains_list2
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = var.connected_domains_list3
  }
  security_domains {
    security_domain_name = var.security_domain_name_list[0]
    connected_domains    = var.connected_domains_list4
    attached_vpc {
      vpc_account_name   = aviatrix_transit_gateway.test_transit_gw.account_name
      vpc_id             = var.aws_vpc_id[0]
      vpc_region         = aviatrix_transit_gateway.test_transit_gw.vpc_reg
    }
    attached_vpc {
      vpc_account_name   = aviatrix_transit_gateway.test_transit_gw.account_name
      vpc_id             = var.aws_vpc_id[1]
      vpc_region         = aviatrix_transit_gateway.test_transit_gw.vpc_reg
    }
  }
  security_domains {
    security_domain_name = var.security_domain_name_list[1]
    attached_vpc {
      vpc_account_name    = aviatrix_transit_gateway.test_transit_gw.account_name
      vpc_id              = var.aws_vpc_id[2]
      vpc_region          = aviatrix_transit_gateway.test_transit_gw.vpc_reg

      customized_routes               = var.custom_routes_list
      disable_local_route_propagation = var.disable_local_route_propagation
    }
  }

  manage_vpc_attachment = true # default is true; if false, must use vpc_attachment resource
  depends_on            = ["aviatrix_vgw_conn.test_vgw_conn"]
}
