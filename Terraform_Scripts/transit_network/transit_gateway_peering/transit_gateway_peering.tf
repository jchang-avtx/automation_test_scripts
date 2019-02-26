## Create Aviatrix transit gateway peering
## Must first create 2 Transit GWs before creating the peering of the two

resource "aviatrix_transit_vpc" "test_transit_gw1" {
  cloud_type        = "${var.aviatrix_cloud_type_aws}"
  account_name      = "${var.aviatrix_cloud_account_name}"
  gw_name           = "${var.aviatrix_transit_gateway_1}"
  enable_nat        = "${var.aviatrix_enable_nat}"
  vpc_id            = "${var.aws_vpc_id[0]}"
  vpc_reg           = "${var.aws_region[0]}"
  vpc_size          = "${var.aws_instance}"
  subnet            = "${var.aws_vpc_public_cidr[0]}"
  # dns_server = # (optional) specify DNS IP, only required while using a custom private DNS for the VPC
  # HA-related parameters are removed for sake of testing speed
  tag_list = "${var.tag_list}" # (optional)
  enable_hybrid_connection = "${var.tgw_enable_hybrid}" # (optional) sign of readiness for TGW connection (ex. false)
  connected_transit = "${var.tgw_enable_connected_transit}" # (optional) specify connected transit status (yes or no)
}

resource "aviatrix_transit_vpc" "test_transit_gw2" {
  cloud_type        = "${var.aviatrix_cloud_type_aws}"
  account_name      = "${var.aviatrix_cloud_account_name}"
  gw_name           = "${var.aviatrix_transit_gateway_2}"
  enable_nat        = "${var.aviatrix_enable_nat}"
  vpc_id            = "${var.aws_vpc_id[1]}"
  vpc_reg           = "${var.aws_region[1]}"
  vpc_size          = "${var.aws_instance}"
  subnet            = "${var.aws_vpc_public_cidr[1]}"
  # dns_server = # (optional) specify DNS IP, only required while using a custom private DNS for the VPC
  # HA-related parameters are removed for sake of testing speed
  tag_list = "${var.tag_list}" # (optional)
  enable_hybrid_connection = "${var.tgw_enable_hybrid}" # (optional) sign of readiness for TGW connection (ex. false)
  connected_transit = "${var.tgw_enable_connected_transit}" # (optional) specify connected transit status (yes or no)
}

resource "aviatrix_transit_gateway_peering" "test_tgw_peering" {
  transit_gateway_name1 = "${var.aviatrix_transit_gateway_1}"
  transit_gateway_name2 = "${var.aviatrix_transit_gateway_2}"
  depends_on            = ["aviatrix_transit_vpc.test_transit_gw1", "aviatrix_transit_vpc.test_transit_gw2"]
}
