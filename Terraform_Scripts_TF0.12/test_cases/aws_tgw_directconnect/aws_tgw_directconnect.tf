# depends on aviatrix_aws_tgw_vpc_attachment's tgw
resource "aws_dx_gateway" "aws_tgw_dx_gw" {
  name              = "aws-tgw-dx-gw"
  amazon_side_asn   = 64512
}

resource "aviatrix_aws_tgw_directconnect" "aws_tgw_dc" {
  tgw_name                    = "testAWSTGW2"
  directconnect_account_name  = "AWSAccess"
  dx_gateway_id               = aws_dx_gateway.aws_tgw_dx_gw.id
  security_domain_name        = "SDN1"
  allowed_prefix              = var.prefix
}

output "aws_tgw_dc_id" {
  value = aviatrix_aws_tgw_directconnect.aws_tgw_dc.id
}
