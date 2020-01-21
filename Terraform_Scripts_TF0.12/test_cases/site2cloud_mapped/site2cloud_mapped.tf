
resource "aviatrix_site2cloud" "s2c_test" {
  vpc_id                        = "vpc-0529919b6ad00473e"
  connection_name               = "s2c_test_conn_name"
  connection_type               = "unmapped"
  remote_gateway_type           = "generic"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = "avxPrimaryGwName"
  backup_gateway_name           = "avxPrimaryGwName-hagw"
  remote_gateway_ip             = "34.232.45.155"
  backup_remote_gateway_ip      = "3.92.103.18"

  remote_subnet_cidr            = "10.202.0.0/16"
  local_subnet_cidr             = "10.123.0.0/16"

  private_route_encryption      = true
  route_table_list              = ["rtb-07986c9ce33117370"]

  remote_gateway_latitude         = 39.0437
  remote_gateway_longitude        = -77.4875

  backup_remote_gateway_latitude  = 39.0437
  backup_remote_gateway_longitude = -77.4875

}

resource "aviatrix_site2cloud" "s2c_test2" {
  vpc_id                        = "vpc-04ca29a568bf2b35f"
  connection_name               = "s2c_test_conn_name_2"
  connection_type               = "unmapped"
  remote_gateway_type           = "generic"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = "onPremRemoteGW"
  backup_gateway_name           = "onPremRemoteGW-hagw"
  remote_gateway_ip             = "34.236.72.194"
  backup_remote_gateway_ip      = "18.204.25.144"

  remote_subnet_cidr            = "10.123.0.0/16"
  local_subnet_cidr             = "10.202.0.0/16"

  depends_on                    = ["aviatrix_site2cloud.s2c_test"]
}

resource "aviatrix_site2cloud" "s2c_test3" {
  vpc_id                        = "vpc-0ac608ef969f34cbd"
  connection_name               = "s2c_test_conn_name_3"
  connection_type               = "mapped"
  remote_gateway_type           = "generic"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = "gateway3"
  backup_gateway_name           = "gateway3-hagw"
  remote_gateway_ip             = "34.232.45.155"
  backup_remote_gateway_ip      = "3.92.103.18"

  remote_subnet_cidr            = "10.202.0.0/16"
  local_subnet_cidr             = "77.77.77.192/28"

  remote_subnet_virtual         = "10.202.0.0/16"
  local_subnet_virtual          = "100.0.0.192/28"

  custom_algorithms             = true
  phase_1_authentication        = "SHA-512"
  phase_1_dh_groups             = "1"
  phase_1_encryption            = "AES-192-CBC"
  phase_2_authentication        = "HMAC-SHA-512"
  phase_2_dh_groups             = "1"
  phase_2_encryption            = "AES-192-CBC"

  depends_on                    = ["aviatrix_site2cloud.s2c_test2"]
}

resource "aviatrix_site2cloud" "s2c_test4" {
  vpc_id                        = "vpc-04ca29a568bf2b35f"
  connection_name               = "s2c_test_conn_name_4"
  connection_type               = "mapped"
  remote_gateway_type           = "generic"
  tunnel_type                   = "udp"
  ha_enabled                    = true

  primary_cloud_gateway_name    = "onPremRemoteGW"
  backup_gateway_name           = "onPremRemoteGW-hagw"
  remote_gateway_ip             = "52.22.209.119"
  backup_remote_gateway_ip      = "3.211.14.238"


  remote_subnet_cidr            = "77.77.77.192/28"
  local_subnet_cidr             = "10.202.0.0/16"

  remote_subnet_virtual         = "100.0.0.192/28"
  local_subnet_virtual          = "10.202.0.0/16"

  custom_algorithms             = true
  phase_1_authentication        = "SHA-384"
  phase_1_dh_groups             = "16"
  phase_1_encryption            = "3DES"
  phase_2_authentication        = "HMAC-SHA-384"
  phase_2_dh_groups             = "16"
  phase_2_encryption            = "3DES"

  depends_on                    = ["aviatrix_site2cloud.s2c_test3"]
}

#################################################
# Outputs
#################################################

output "s2c_test_id" {
  value = aviatrix_site2cloud.s2c_test.id
}

output "s2c_test2_id" {
  value = aviatrix_site2cloud.s2c_test2.id
}

output "s2c_test3_id" {
  value = aviatrix_site2cloud.s2c_test3.id
}

output "s2c_test4_id" {
  value = aviatrix_site2cloud.s2c_test4.id
}
