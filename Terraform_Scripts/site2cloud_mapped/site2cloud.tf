## Creates and manages an Aviatrix Site2Cloud connection
## Note: To test the S2C with backup gateways enabled, you must comment out the gateways and uncomment out
## the respective backup parameters to be tested

## This test case is testing mapped connections (using 3 sites, no HA, and encryption)
## Please see Site2Cloud: Mapped Connections notes

## NOTE: site2cloud_2 and _3 are commented out atm due to Mantis: 9150; diff issues with no custom_algorithms set
## EDIT: 9150 is still an issue, but custom_algorithms currently postponed to 4.6 (14 may 2019)

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

#################################################

# # tunnel from local (cloud) to on-prem
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

  # ssl_server_pool = "192.168.44.0/24" # (optional) (specifies for tunnel type TCP)

  depends_on = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2", "aviatrix_gateway.test_gateway3"]
}

# # tunnel from on-prem to local (cloud)
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

# tunnel from gateway3 to gateway2 (cloud)
resource "aviatrix_site2cloud" "s2c_test3" {
  vpc_id = "vpc-mnop" # avtxgw3's vpc to avtxgw2's vpc
  connection_name = "avx_s2c_conn_name3"
  connection_type = "mapped"
  remote_gateway_type = "generic"
  tunnel_type = "udp"
  ha_enabled = "no"

  primary_cloud_gateway_name = "avtxgw3"
  remote_gateway_ip = "5.5.5.5" # onPremRemoteGW's ip (gw2)

  # pre_shared_key = ""
  # backup_pre_shared_key = ""

  remote_subnet_cidr = "10.23.0.0/24" # gw2's cidr
  local_subnet_cidr = "10.25.0.0/24" # avtxgw3's cidr

  remote_subnet_virtual = "10.23.0.0/24" # avtxgw2's vpc virtual cidr (must be same as real)
  local_subnet_virtual = "100.0.0.0/24" # avtxgw3's vpc virtual cidr (must match subnet mask of real)
  
  # 4.6 see id = (8287) (9150)
  custom_algorithms = true # boolean values only
  phase_1_authentication = "SHA-1"
  phase_1_dh_groups = "2"
  phase_1_encryption = "AES-256-CBC"
  phase_2_authentication = "HMAC-SHA-1"
  phase_2_dh_groups = "2"
  phase_2_encryption = "AES-256-CBC"

  depends_on = ["aviatrix_site2cloud.s2c_test2"]
}

# tunnel from gateway2 to gateway3
resource "aviatrix_site2cloud" "s2c_test4" {
  vpc_id = "vpc-ghijkl"
  connection_name = "avx_s2c_conn_name4"
  connection_type = "mapped"
  remote_gateway_type = "generic"
  tunnel_type = "udp"
  ha_enabled = "no"

  primary_cloud_gateway_name = "avtxgw2"
  remote_gateway_ip = "4.4.4.4" # avtxgw3's ip

  # pre_shared_key = ""
  # backup_pre_shared_key = ""

  remote_subnet_cidr = "10.25.0.0/24" # avtxgw3's cidr
  local_subnet_cidr = "10.23.0.0/24" # avtxgw2's cidr

  remote_subnet_virtual = "100.0.0.0/24" # avtxgw3's vpc virtual cidr
  local_subnet_virtual = "10.23.0.0/24"

  # 4.6 see id = (8287) (9150)
  custom_algorithms = true
  phase_1_authentication = "SHA-512"
  phase_1_dh_groups = "16"
  phase_1_encryption = "AES-128-CBC"
  phase_2_authentication = "HMAC-SHA-512"
  phase_2_dh_groups = "16"
  phase_2_encryption = "AES-128-CBC"

  depends_on = ["aviatrix_site2cloud.s2c_test3"]
}
