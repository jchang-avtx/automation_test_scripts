# -Sample Aviatrix terraform configuration to create complete transit VPC solution
# This configuration creates a cloud account on Aviatrix controller, launches transit VPC, creates VGW connection
# with transit VPC
# Launches a spoke GW, and attach with transit VPC.
 
# Create account with IAM roles
resource "aviatrix_account" "access_account" {
  account_name = "${var.mylocal_cloud_account_name}"
  cloud_type = 1
  aws_iam = "true"
  aws_account_number = "${var.aws_account_number}"
}

resource "aws_vpn_gateway" "vpn_gw" {
  tags {
    Name = "site2cloud-vgw"
  }
  depends_on = ["aviatrix_account.access_account"]
}
 
#OnPrem-GW
resource "aviatrix_gateway" "OnPrem-GW" {
  cloud_type = 1
  account_name = "${aviatrix_account.access_account.account_name}"
  gw_name = "${var.aviatrix_gateway_name}"
  vpc_id = "${aws_vpc.OnPrem-VPC.id}"
  vpc_reg = "${var.aws_region}"
  vpc_size = "${var.aws_instance}"
  vpc_net = "${aws_subnet.OnPrem-VPC-public.cidr_block}"
  depends_on = ["aviatrix_account.access_account"]
}

# Aviatrix site2cloud connection facing AWS VGW
# tunnel1
resource "aviatrix_site2cloud" "onprem-vgw" {
  primary_cloud_gateway_name = "${aviatrix_gateway.OnPrem-GW.gw_name}" 
  vpc_id = "${aws_vpc.OnPrem-VPC.id}"
  connection_name = "${var.connection_name1}"
  connection_type = "unmapped"
  tunnel_type = "udp"
  remote_gateway_type = "aws"
  remote_gateway_ip = "${aws_vpn_connection.onprem.tunnel1_address}"
  remote_subnet_cidr = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  pre_shared_key = "${aws_vpn_connection.onprem.tunnel1_preshared_key}"
  depends_on = ["aviatrix_gateway.OnPrem-GW"]
}
