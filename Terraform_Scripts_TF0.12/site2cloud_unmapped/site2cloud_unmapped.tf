## Creates and manages a Aviatrix Site2Cloud connections

# Create Aviatrix AWS gateway to act as our "Local"
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "avxPrimaryGwName"
  vpc_id              = "vpc-0529919b6ad00473e"
  vpc_reg             = "us-east-1"
  gw_size             = "t2.micro"
  subnet              = "10.122.0.0/16"

  peering_ha_subnet   = "10.122.0.0/16"
  peering_ha_gw_size  = "t2.micro"

  allocate_new_eip    = false
  eip                 = "34.236.72.194"
  peering_ha_eip      = "18.204.25.144"
}

# Create Aviatrix AWS gateway to act as our on-prem / "Remote" server
resource "aviatrix_gateway" "test_gateway2" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "onPremRemoteGW"
  vpc_id              = "vpc-04ca29a568bf2b35f"
  vpc_reg             = "us-east-1"
  gw_size             = "t2.micro"
  subnet              = "10.202.0.0/16"

  peering_ha_subnet   = "10.202.0.0/16"
  peering_ha_gw_size  = "t2.micro"

  allocate_new_eip    = false
  eip                 = "34.232.45.155"
  peering_ha_eip      = "3.92.103.18"
}

## Test case: with 3 gateways/ more than 2 connections
resource "aviatrix_gateway" "test_gateway3" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "gateway3"
  vpc_id              = "vpc-0ac608ef969f34cbd"
  vpc_reg             = "us-east-1"
  gw_size             = "t2.micro"
  subnet              = "77.77.77.192/28"

  peering_ha_subnet   = "77.77.77.192/28"
  peering_ha_gw_size  = "t2.micro"

  allocate_new_eip    = false
  eip                 = "52.22.209.119"
  peering_ha_eip      = "3.211.14.238"
}

#################################################

resource "aviatrix_site2cloud" "s2c_test" {
  vpc_id                        = aviatrix_gateway.test_gateway1.vpc_id
  connection_name               = "s2c_test_conn_name"
  connection_type               = "unmapped"
  remote_gateway_type           = "avx"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = aviatrix_gateway.test_gateway1.gw_name
  backup_gateway_name           = "${aviatrix_gateway.test_gateway1.gw_name}-hagw"
  remote_gateway_ip             = aviatrix_gateway.test_gateway2.eip
  backup_remote_gateway_ip      = aviatrix_gateway.test_gateway2.peering_ha_eip

  # pre_shared_key = var.pre_shared_key # (Optional) Auto-generated if not specified
  # backup_pre_shared_key = var.pre_shared_key_backup # (Optional)

  remote_subnet_cidr            = aviatrix_gateway.test_gateway2.subnet
  local_subnet_cidr             = aviatrix_gateway.test_gateway1.subnet

  ssl_server_pool               = "192.168.45.0/24"
  enable_dead_peer_detection    = true

  depends_on                    = ["aviatrix_gateway.test_gateway1", "aviatrix_gateway.test_gateway2", "aviatrix_gateway.test_gateway3"]
}

resource "aviatrix_site2cloud" "s2c_test2" {
  vpc_id                        = aviatrix_gateway.test_gateway2.vpc_id
  connection_name               = "s2c_test_conn_name_2"
  connection_type               = "unmapped"
  remote_gateway_type           = "avx"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = aviatrix_gateway.test_gateway2.gw_name
  backup_gateway_name           = "${aviatrix_gateway.test_gateway2.gw_name}-hagw"
  remote_gateway_ip             = aviatrix_gateway.test_gateway1.eip
  backup_remote_gateway_ip      = aviatrix_gateway.test_gateway1.peering_ha_eip

  pre_shared_key                = var.pre_shared_key
  backup_pre_shared_key         = var.pre_shared_key_backup

  remote_subnet_cidr            = aviatrix_gateway.test_gateway1.subnet
  local_subnet_cidr             = aviatrix_gateway.test_gateway2.subnet

  # ssl_server_pool               = "192.168.45.0/24"
  enable_dead_peer_detection    = true

  depends_on                    = ["aviatrix_site2cloud.s2c_test"]
}

resource "aviatrix_site2cloud" "s2c_test3" {
  vpc_id                        = aviatrix_gateway.test_gateway3.vpc_id
  connection_name               = "s2c_test_conn_name_3"
  connection_type               = "unmapped"
  remote_gateway_type           = "avx"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = aviatrix_gateway.test_gateway3.gw_name
  backup_gateway_name           = "${aviatrix_gateway.test_gateway3.gw_name}-hagw"
  remote_gateway_ip             = aviatrix_gateway.test_gateway1.eip
  backup_remote_gateway_ip      = aviatrix_gateway.test_gateway1.peering_ha_eip

  remote_subnet_cidr            = aviatrix_gateway.test_gateway1.subnet
  local_subnet_cidr             = aviatrix_gateway.test_gateway3.subnet

  # ssl_server_pool               = "192.168.45.0/24"
  enable_dead_peer_detection    = false

  depends_on                    = ["aviatrix_site2cloud.s2c_test2"]
}

resource "aviatrix_site2cloud" "s2c_test4" {
  vpc_id                        = aviatrix_gateway.test_gateway1.vpc_id
  connection_name               = "s2c_test_conn_name_4"
  connection_type               = "unmapped"
  remote_gateway_type           = "avx"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = aviatrix_gateway.test_gateway1.gw_name
  backup_gateway_name           = "${aviatrix_gateway.test_gateway1.gw_name}-hagw"
  remote_gateway_ip             = aviatrix_gateway.test_gateway3.eip
  backup_remote_gateway_ip      = aviatrix_gateway.test_gateway3.peering_ha_eip

  remote_subnet_cidr            = aviatrix_gateway.test_gateway3.subnet
  local_subnet_cidr             = aviatrix_gateway.test_gateway1.subnet

  # ssl_server_pool               = "192.168.45.0/24"
  enable_dead_peer_detection    = false

  depends_on = ["aviatrix_site2cloud.s2c_test3"]
}
