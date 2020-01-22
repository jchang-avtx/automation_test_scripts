## Create AWS gateway with insane mode enabled

resource "aviatrix_gateway" "insane_aws_gw" {
  cloud_type                = 1
  account_name              = "AWSAccess"
  gw_name                   = "insaneAWSGW"
  vpc_id                    = "vpc-ba3c12dd"
  vpc_reg                   = "us-west-1"

  insane_mode               = true
  subnet                    = "172.31.32.0/26"
  insane_mode_az            = "us-west-1a"
  gw_size                   = "c5.large"

  peering_ha_subnet         = "172.31.32.192/26"
  peering_ha_insane_mode_az = "us-west-1b"
  peering_ha_gw_size        = "c5.large"
}

output "insane_aws_gw_id" {
  value = aviatrix_gateway.insane_aws_gw.id
}
