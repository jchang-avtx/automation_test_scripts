## Testing a regular Aviatrix gateway with ha-enabled

## Additional test case:
# 1. attempt apply without specifying peering_ha_gw_size; gw should not be created, error returned

resource "aviatrix_gateway" "testGW1" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "testGW1"
  vpc_id = "vpc-abc123"
  vpg_reg = "us-east-1"
  vpc_size = "${var.aws_instance_size}"
  vpc_net = "10.0.0.0/16"
  tag_list = "${var.aws_gateway_tag_list}" # optional
  enable_nat = "${var.enable_nat}"

  peering_ha_subnet = "10.0.0.0/24"
  peering_ha_gw_size = "${var.aws_ha_gw_size}" # (as of 4.3; required if peering_ha_subnet is set)
  peering_ha_eip = "7.7.7.7"

  allocate_new_eip = "off"
  eip = "8.8.8.8"
}
