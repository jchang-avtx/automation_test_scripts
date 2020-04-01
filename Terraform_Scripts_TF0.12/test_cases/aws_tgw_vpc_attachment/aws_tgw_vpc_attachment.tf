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
  customized_routes     = var.customized_routes
  disable_local_route_propagation = var.disable_local_route_propagation
}

## AWS_TGW_DIRECTCONNECT
# depends on aviatrix_aws_tgw_vpc_attachment's tgw
resource "aws_dx_gateway" "aws_tgw_dx_gw" {
  name              = "aws-tgw-dx-gw"
  amazon_side_asn   = 64512
}

resource "aviatrix_aws_tgw_directconnect" "aws_tgw_dc" {
  tgw_name                    = aviatrix_aws_tgw.test_aws_tgw2.tgw_name
  directconnect_account_name  = "AWSAccess"
  dx_gateway_id               = aws_dx_gateway.aws_tgw_dx_gw.id
  security_domain_name        = "SDN1"
  allowed_prefix              = var.prefix

  enable_learned_cidrs_approval = var.enable_learned_cidrs_approval
}

## OUTPUTS
output "tgw_vpc_attach_test_id" {
  value = aviatrix_aws_tgw_vpc_attachment.tgw_vpc_attach_test.id
}

output "aws_tgw_dc_id" {
  value = aviatrix_aws_tgw_directconnect.aws_tgw_dc.id
}
