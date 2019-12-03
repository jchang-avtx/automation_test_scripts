# depends on aviatrix_aws_tgw_vpc_attachment's tgw

resource "aviatrix_aws_tgw_directconnect" "aws_tgw_dc" {
  tgw_name                    = "testAWSTGW2"
  directconnect_account_name  = "AWSAccess"
  dx_gateway_id               = "629dddaa-cc3d-41da-b54e-83bb43b6934b"
  security_domain_name        = "SDN1"
  allowed_prefix              = var.prefix
}

output "aws_tgw_dc_id" {
  value = aviatrix_aws_tgw_directconnect.aws_tgw_dc.id
}
