## Test case: test regular gateway

resource "aviatrix_gateway" "testGW1" {
  cloud_type          = 1
  account_name        = "AnthonyPrimaryAccess"
  gw_name             = "testGW1"
  vpc_id              = "vpc-0086065966b807866"
  vpc_reg             = "us-east-1"
  gw_size             = var.aws_instance_size
  subnet              = "10.0.2.0/24"

  tag_list            = var.aws_gateway_tag_list
  enable_snat         = var.enable_snat

  allocate_new_eip    = false
  eip                 = "3.92.103.18"

  peering_ha_subnet   = "10.0.2.0/24"
  peering_ha_gw_size  = var.aws_ha_gw_size
  peering_ha_eip      = "18.204.25.144"
}
