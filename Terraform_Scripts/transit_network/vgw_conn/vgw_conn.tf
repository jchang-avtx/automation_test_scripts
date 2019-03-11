# Manage Aviatrix Controller TransitGW to VGW Connection

# Once this resource is created, VGW can be disconnected
# from transit GW by destroying this resource using command:
# terraform destroy --target aviatrix_vgw_conn.test_vgw_conn.

# Need to create transit_vpc (gw) before establishing a vgw conn
resource "aviatrix_transit_vpc" "test_transit_gw" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "testtransitGW1"
  vpc_id = "vpc-abcd123"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  subnet = "10.1.0.0/24"
  # ha_subnet = "10.1.0.0/24"
  # ha_gw_size = "t2.micro"
  tag_list = ["k1:v1", "k2:v2"]
  enable_hybrid_connection = true
  connected_transit = "yes"
}

resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name = "${var.tgw_vgw_conn_name}" # Connection name
  gw_name = "${var.aviatrix_gateway_name}" # existing transitGW name
  vpc_id = "${var.aws_vpc_id}" # VPC ID of transitGW
  bgp_vgw_id = "${var.aws_vgw_id}" # VGW ID
  bgp_local_as_num = "${var.bgp_local_as}"
  depends_on = ["aviatrix_transit_vpc.test_transit_gw"]
}
