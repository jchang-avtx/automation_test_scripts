## Creates and manages an Aviatrix Site2Cloud connection

# Create Aviatrix AWS gateway to act as our "Local"
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "avtxgw1"
  vpc_id = "vpc-abcdef"
  vpc_reg = "us-west-1"
  vpc_size = "t2.micro"
  vpc_net = "10.0.0.0/24"
  tag_list = ["k1:v1","k2:v2"]
}

# Create Aviatrix AWS gateway to act as our on-prem / "Remote" server
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "avtxgw2"
  vpc_id = "vpc-ghijkl"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  vpc_net = "11.0.0.0/24"
  tag_list = ["k1:v1","k2:v2"]
}

resource "aviatrix_site2cloud" "s2c_test" {
  vpc_id = "${var.aws_vpc_id}"
  connection_name = "${var.avx_s2c_conn_name}"
  connection_type = "${var.avx_s2c_conn_type}"
  remote_gateway_type = "${var.remote_gw_type}" # "generic", "avx", "aws", "azure", "sonicwall"
  tunnel_type = "${var.avx_s2c_tunnel_type}" # "udp" , "tcp"
  ha_enabled = "${var.ha_enabled}" # (Optional) "true" or "false"

  primary_cloud_gateway_name = "${var.avx_gw_name}"
  backup_gateway_name = "${var.avx_gw_name_backup}" # (Optional)
  remote_gateway_ip = "${var.remote_gw_ip}"
  pre_shared_key = "${var.pre_shared_key}" # (Optional) Auto-generated if not specified
  backup_pre_shared_key = "${var.pre_shared_key_backup}" # (Optional)
  remote_subnet_cidr = "${var.remote_subnet_cidr}" # on-prem's subnet cidr
  local_subnet_cidr = "${var.local_subnet_cidr}" # (Optional)

  depends_on = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2"]
}
