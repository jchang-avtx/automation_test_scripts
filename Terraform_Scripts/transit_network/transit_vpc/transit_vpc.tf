# Manage Aviatrix Transit Network Gateways

# Create a transit VPC.
# Omit ha_subnet to launch transit VPC without HA.
# HA subnet can later be added or deleted to enable/disable HA in transit VPC

## Additional test case:
# 1. attempt apply without specifying ha_gw_size; gw should not be created, error returned

resource "aviatrix_transit_vpc" "test_transit_gw" {
  cloud_type        = "${var.aviatrix_cloud_type_aws}"
  account_name      = "${var.aviatrix_cloud_account_name}"
  gw_name           = "${var.aviatrix_gateway_name}"
  enable_nat        = "${var.aviatrix_enable_nat}"
  vpc_id            = "${var.aws_vpc_id}"
  vpc_reg           = "${var.aws_region}"
  vpc_size          = "${var.aws_instance}"
  subnet            = "${var.aws_vpc_public_cidr}"
  # dns_server = # (optional) specify DNS IP, only required while using a custom private DNS for the VPC // deprecated 4.2
  ha_subnet = "${var.aviatrix_ha_subnet}"# (optional) HA subnet. Setting to empty/unset will disable HA. Setting to valid subnet will create an HA gateway in the subnet
  ha_gw_size = "${var.aviatrix_ha_gw_size}"# (optional) HA gw size. Mandatory if HA is enabled (ex. "t2.micro")

  # tag_list = "${var.tag_list}" # optional
  enable_hybrid_connection = "${var.tgw_enable_hybrid}" # (optional) enable to prep for TGW attachment; allows you to skip Step5 in TGW orchestrator
  connected_transit = "${var.tgw_enable_connected_transit}" # (optional) specify connected transit status (yes or no)
}
