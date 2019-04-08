## Creates and manages an Aviatrix Site2Cloud connection(s)
## Creates 3 gateways, and creates 4 connections: 2 for (to&from) local-to-on-prem, and local-to-gw3/site3

# Create Aviatrix AWS gateway to act as our "Local"
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "avxPrimaryGwName"
  vpc_id = "vpc-abcdef"
  vpc_reg = "us-west-1"
  vpc_size = "t2.micro"
  vpc_net = "10.20.1.0/24"
  allocate_new_eip = "off"
  eip = "6.6.6.6"
  # peering_ha_subnet = xxxx # uncomment before creation to test s2c ha_enabled
  # peering_ha_eip = xxxx # uncomment before creation to test s2c ha_enabled
}

# Create Aviatrix AWS gateway to act as our on-prem / "Remote" server
resource "aviatrix_gateway" "test_gateway2" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "avtxgw2"
  vpc_id = "vpc-ghijkl"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  vpc_net = "10.23.0.0/24"
  allocate_new_eip = "off"
  eip = "5.5.5.5"
  # peering_ha_subnet = xxxx # uncomment before creation to test s2c ha_enabled = "yes"
  # peering_ha_eip = xxxx  # uncomment before creation to test s2c ha_enabled = "yes"
}

resource "aviatrix_gateway" "test_gateway3" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "avtxgw3"
  vpc_id = "vpc-mnop"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  vpc_net = "10.25.0.0/24"
  allocate_new_eip = "off"
  eip = "4.4.4.4"
  # peering_ha_subnet = xxxx # uncomment before creation to test s2c ha_enabled = "yes"
  # peering_ha_eip = xxxx # uncomment before creation to test s2c ha_enabled = "yes"
}

# tunnel from local (cloud) to on-prem
resource "aviatrix_site2cloud" "s2c_test" {
  vpc_id = "vpc-abcdef"
  connection_name = "avx_s2c_conn_name"
  connection_type = "ummapped"
  remote_gateway_type = "generic" # "generic", "avx", "aws", "azure", "sonicwall"
  tunnel_type = "udp" # "udp" , "tcp"
  ha_enabled = "no" # (Optional) "yes" or "no"

  primary_cloud_gateway_name = "avxPrimaryGwName" # local gw name
  # backup_gateway_name = "${var.avx_gw_name_backup}" # uncomment before creation to test s2c ha_enabled = "yes"
  remote_gateway_ip = "5.5.5.5"
  # backup_remote_gateway_ip = "${var.remote_gw_ip_backup}" # uncomment before creation to test s2c ha_enabled = "yes"
  # pre_shared_key = "${var.pre_shared_key}" # (Optional) Auto-generated if not specified
  # backup_pre_shared_key = "${var.pre_shared_key_backup}" # (Optional) # can uncomment before creation to test s2c ha_enabled = "yes"
  remote_subnet_cidr = "10.23.0.0/24" # on-prem's subnet cidr
  local_subnet_cidr = "10.20.1.0/24" # (Optional)

  depends_on = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2", "aviatrix_gateway.test_gateway3"]
}

# tunnel from on-prem to local (cloud)
resource "aviatrix_site2cloud" "s2c_test2" {
  vpc_id = "vpc-ghijkl" # avtxgw2's vpc
  connection_name = "avx_s2c_conn_name2"
  connection_type = "unmapped"
  remote_gateway_type = "generic"
  tunnel_type = "udp"
  ha_enabled = "no"

  primary_cloud_gateway_name = "avtxgw2"
  # backup_gateway_name = "avtxgw2-hagw"
  remote_gateway_ip = "6.6.6.6"
  # backup_remote_gateway_ip = ""
  # pre_shared_key = ""
  # backup_pre_shared_key = ""
  remote_subnet_cidr = "10.20.1.0/24" # avxPrimaryGwName's cidr
  local_subnet_cidr = "10.23.0.0/24" # on-prem's cidr

  depends_on = ["aviatrix_site2cloud.s2c_test"]
}

# tunnel from gateway3 to local (cloud)
resource "aviatrix_site2cloud" "s2c_test3" {
  vpc_id = "vpc-mnop" # avtxgw3's vpc
  connection_name = "avx_s2c_conn_name3"
  connection_type = "unmapped"
  remote_gateway_type = "generic"
  tunnel_type = "udp"
  ha_enabled = "no"

  primary_cloud_gateway_name = "avtxgw3"
  # backup_gateway_name = "avtxgw3-hagw"
  remote_gateway_ip = "6.6.6.6" # avxPrimaryGwName's ip
  # backup_remote_gateway_ip = ""
  # pre_shared_key = ""
  # backup_pre_shared_key = ""
  remote_subnet_cidr = "10.20.1.0/24" # avxPrimaryGwName's cidr
  local_subnet_cidr = "10.25.0.0/24" # avtxgw3's cidr

  depends_on = ["aviatrix_site2cloud.s2c_test2"]
}

# tunnel from local (cloud) to gateway3
resource "aviatrix_site2cloud" "s2c_test4" {
  vpc_id = "vpc-abcdef" # avxPrimaryGwName's vpc
  connection_name = "avx_s2c_conn_name4"
  connection_type = "unmapped"
  remote_gateway_type = "generic"
  tunnel_type = "udp"
  ha_enabled = "no"

  primary_cloud_gateway_name = "avxPrimaryGwName"
  # backup_gateway_name = "avxPrimaryGwName-hagw"
  remote_gateway_ip = "4.4.4.4" # avtxgw3's ip
  # backup_remote_gateway_ip = ""
  # pre_shared_key = ""
  # backup_pre_shared_key = ""
  remote_subnet_cidr = "10.25.0.0/24" # avtxgw3's cidr
  local_subnet_cidr = "10.20.1.0/24" # avxPrimaryGwName's cidr

  depends_on = ["aviatrix_site2cloud.s2c_test3"]
}
