## MANTIS 11687: diff on site2cloud backup_gateway_name and backup_remote_gateway_ip
## CLOSED : they are setting up ha-gw incorrectly. the infrastructure/ setup for failover is incorrect

# aviatrix_gateway.S2C_GW_Vir_Backup:
resource "aviatrix_gateway" "S2C_GW_Vir_Backup" {
  account_name            = "AWSAccess"
  allocate_new_eip        = true
  cloud_type              = 1
  enable_elb              = false
  enable_ldap             = false
  enable_snat             = false
  enable_vpc_dns_server   = false
  enable_vpn_nat          = true
  gw_name                 = "s2c-gw-backup"
  gw_size                 = "t2.micro"
  insane_mode             = false
  max_vpn_conn            = "100"
  saml_enabled            = false
  single_az_ha            = false
  split_tunnel            = true
  subnet                  = "77.77.77.192/28"
  vpc_id                  = "vpc-0ac608ef969f34cbd"
  vpc_reg                 = "us-east-1"
  vpn_access              = true
  vpn_cidr                = "192.168.45.0/24"
}

# aviatrix_gateway.S2C_GW_Vir_Primary:
resource "aviatrix_gateway" "S2C_GW_Vir_Primary" {
  account_name            = "AWSAccess"
  allocate_new_eip        = true
  cloud_type              = 1
  enable_elb              = false
  enable_ldap             = false
  enable_snat             = false
  enable_vpc_dns_server   = false
  enable_vpn_nat          = true
  gw_name                 = "s2c-gw-primary"
  gw_size                 = "t2.micro"
  insane_mode             = false
  max_vpn_conn            = "100"
  saml_enabled            = false
  single_az_ha            = false
  split_tunnel            = true
  subnet                  = "10.0.2.0/24"
  vpc_id                  = "vpc-0086065966b807866"
  vpc_reg                 = "us-east-1"
  vpn_access              = true
  vpn_cidr                = "192.168.43.0/24"
}

resource "aviatrix_gateway" "onPrem" {
  account_name            = "AWSAccess"
  allocate_new_eip        = true
  cloud_type              = 1
  enable_elb              = false
  enable_ldap             = false
  enable_snat             = false
  enable_vpc_dns_server   = false
  gw_name                 = "onprem"
  gw_size                 = "t2.micro"
  insane_mode             = false
  saml_enabled            = false
  single_az_ha            = true
  subnet                  = "99.99.99.96/28"
  vpc_id                  = "vpc-0b92c79340ba016ee"
  vpc_reg                 = "eu-central-1"
  vpn_access              = false
}

resource "aviatrix_gateway" "onPrem_backup" {
  account_name            = "AWSAccess"
  allocate_new_eip        = true
  cloud_type              = 1
  enable_elb              = false
  enable_ldap             = false
  enable_snat             = false
  enable_vpc_dns_server   = false
  gw_name                 = "onprembackup"
  gw_size                 = "t2.micro"
  insane_mode             = false
  saml_enabled            = false
  single_az_ha            = true
  subnet                  = "33.33.33.64/28"
  vpc_id                  = "vpc-0b730945d29ccfa9e"
  vpc_reg                 = "eu-central-1"
  vpn_access              = false
}

# aviatrix_site2cloud.test_s2c:
# resource "aviatrix_site2cloud" "test_s2c" {
#     # backup_pre_shared_key = "backupkey"
#     connection_name = "cloud_to_onprem"
#     connection_type = "unmapped"
#     enable_dead_peer_detection = true
#     ha_enabled = true ## <<<<<< CULPRIT OF THE ISSUE
#     local_subnet_cidr = aviatrix_gateway.S2C_GW_Vir_Primary.subnet
#     # pre_shared_key = "presharekey"
#     primary_cloud_gateway_name = aviatrix_gateway.S2C_GW_Vir_Primary.gw_name
#     private_route_encryption = false
#     remote_gateway_ip = aviatrix_gateway.onPrem.public_ip
#     remote_gateway_type = "generic"
#     remote_subnet_cidr = aviatrix_gateway.onPrem.subnet
#     tunnel_type = "udp"
#     vpc_id = aviatrix_gateway.S2C_GW_Vir_Primary.vpc_id
#     depends_on = ["aviatrix_gateway.S2C_GW_Vir_Backup", "aviatrix_gateway.S2C_GW_Vir_Primary"]
# }

resource "aviatrix_site2cloud" "test_s2c" {
  vpc_id = aviatrix_gateway.S2C_GW_Vir_Primary.vpc_id
  connection_name       = "cloud_to_onprem"
  connection_type       = "unmapped"
  remote_gateway_type   = "generic"
  tunnel_type           = "udp"
  ha_enabled            = true

  primary_cloud_gateway_name  = aviatrix_gateway.S2C_GW_Vir_Primary.gw_name
  backup_gateway_name         = aviatrix_gateway.S2C_GW_Vir_Backup.gw_name
  remote_gateway_ip           = aviatrix_gateway.onPrem.eip
  backup_remote_gateway_ip    = aviatrix_gateway.onPrem_backup.eip

  remote_subnet_cidr  = aviatrix_gateway.onPrem.subnet
  local_subnet_cidr   = aviatrix_gateway.S2C_GW_Vir_Primary.subnet

  enable_dead_peer_detection  = false
  private_route_encryption    = false

  custom_algorithms = true
  phase_1_authentication        = "SHA-384"
  phase_1_dh_groups             = "16"
  phase_1_encryption            = "3DES"
  phase_2_authentication        = "HMAC-SHA-384"
  phase_2_dh_groups             = "16"
  phase_2_encryption            = "3DES"
}

output "test_s2c_id" {
  value = aviatrix_site2cloud.test_s2c.id
}
