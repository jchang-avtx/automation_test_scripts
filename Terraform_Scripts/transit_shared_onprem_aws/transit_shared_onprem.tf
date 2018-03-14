# Aviatrix Systems
# 14March2018 - edsel@aviatrix.com
# ----------------------------------------
# Auto deploy the following:
# 1. create temporary aviatrix account for AWS.
# 2. create AWS transit, spoke, onprem VPCs.
# 3. create Aviatrix transit gateway, spoke gateway, and onprem gateway.
# 4. create Aviatrix site2cloud connection to VGW
# 5. create AWS linux instance per spoke and onprem VPCs.
#
 
# Create account with IAM roles
resource "aviatrix_account" "temp_account" {
  account_name = "${var.account_name}"
  account_password = "${var.account_password}"
  account_email = "${var.account_email}"
  cloud_type = 1
  aws_account_number = "${var.aws_account_number}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
}

resource "aws_vpn_gateway" "vpn_gw" {
  tags {
    Name = "my-vgw"
  }
  depends_on = ["aws_route_table_association.transit-VPC-ra","aviatrix_account.temp_account"]
}
 
# Create transit VPC
# Omit ha_subnet to launch transit VPC without HA.
# ha_subnet can be later added or deleted to enable/disable HA in transit VPC
 
resource "aviatrix_transit_vpc" "test_transit_gw" {
  count = "${var.transit}"
  cloud_type = 1
  account_name = "${var.account_name}"
  gw_name= "${var.static_transit_gateway_name}"
  vpc_id = "${element(aws_vpc.transit-VPC.*.id,count.index)}"
  vpc_reg = "${var.region1}"
  vpc_size = "${var.t2instance}"
  subnet = "${element(aws_subnet.transit-VPC-public.*.cidr_block,count.index)}"
  depends_on = ["aws_route_table_association.transit-VPC-ra","aws_route_table_association.spoke-VPC-ra","aviatrix_account.temp_account"]
}

## Connect VGW connection with transit VPC.
resource "aviatrix_vgw_conn" "test_vgw_conn" {
  count = "${var.transit}"
  conn_name = "${var.vgw_connection_name}"
  gw_name = "${var.static_transit_gateway_name}"
  vpc_id = "${element(aws_vpc.transit-VPC.*.id,count.index)}"
  bgp_vgw_id = "${aws_vpn_gateway.vpn_gw.id}"
  bgp_local_as_num = "${var.bgp_local_as}"
  depends_on = ["aviatrix_transit_vpc.test_transit_gw","aviatrix_account.temp_account","aviatrix_transit_vpc.test_transit_gw"]
}

## Create Spoke Gateways and connect to transit GW
resource "aviatrix_spoke_vpc" "test_spoke" {
  count = "${var.spoke_gateways}"
  account_name = "${var.account_name}"
  cloud_type = 1
  gw_name= "spoke-GW-${count.index}-${var.region1}"
  vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
  vpc_reg = "${var.region1}"
  vpc_size = "${var.t2instance}"
  subnet = "${element(aws_subnet.spoke-VPC-public.*.cidr_block,count.index)}"
  transit_gw = "${var.static_transit_gateway_name}"
  depends_on = ["aviatrix_vgw_conn.test_vgw_conn","aviatrix_transit_vpc.test_transit_gw","aws_vpc.spoke-VPC","aws_route_table_association.spoke-VPC-ra","aviatrix_account.temp_account" ]
}

## Create Shared Services Gateways and connect to transit GW
resource "aviatrix_spoke_vpc" "shared_services" {
  count = "${var.shared_gateways}"
  account_name = "${var.account_name}"
  cloud_type = 1
  gw_name= "shared-services-GW-${count.index}-${var.region1}"
  vpc_id = "${element(aws_vpc.shared-VPC.*.id,count.index)}"
  vpc_reg = "${var.region1}"
  vpc_size = "${var.t2instance}"
  subnet = "${element(aws_subnet.shared-VPC-public.*.cidr_block,count.index)}"
  transit_gw = "${var.static_transit_gateway_name}"
  depends_on = ["aviatrix_vgw_conn.test_vgw_conn","aviatrix_transit_vpc.test_transit_gw","aws_vpc.shared-VPC","aws_route_table_association.shared-VPC-ra","aviatrix_account.temp_account" ]
}

#OnPrem-GW
resource "aviatrix_gateway" "OnPrem-GW" {
  cloud_type = 1
  account_name = "${var.account_name}"
  gw_name = "OnPrem-GW"
  vpc_id = "${aws_vpc.OnPrem-VPC.id}"
  vpc_reg = "${var.region1}"
  vpc_size = "${var.t2instance}"
  vpc_net = "${aws_subnet.OnPrem-VPC-public.cidr_block}"
  depends_on = ["aviatrix_spoke_vpc.test_spoke"]
}

# Encrypteed peering from shared-services GWs to spoke GWs
resource "aviatrix_tunnel" "shared-to-spoke"{
  count = "${var.spoke_gateways}"
  vpc_name1 = "spoke-GW-${count.index}-${var.region1}"
  vpc_name2 = "${aviatrix_spoke_vpc.shared_services.gw_name}"
  cluster   = "no"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  depends_on = ["aviatrix_spoke_vpc.test_spoke"]
}

# Aviatrix site2cloud connection facing AWS VGW
resource "aviatrix_site2cloud" "onprem-vgw" {
  gw_name = "${aviatrix_gateway.OnPrem-GW.gw_name}" 
  vpc_id = "${aws_vpc.OnPrem-VPC.id}",
  conn_name = "s2c_to_vgw",
  remote_gw_type = "AWS VGW",
  remote_gw_ip = "${aws_vpn_connection.onprem.tunnel1_address}",
  remote_subnet = "${aws_subnet.spoke-VPC-public.cidr_block},${aws_subnet.shared-VPC-public.cidr_block}",
  pre_shared_key = "${aws_vpn_connection.onprem.tunnel1_preshared_key}"
}

