# initial creation

# input your Avx controller credentials here
aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

aws_vpc_id = "vpc-abcd1234"
avx_s2c_conn_name = "s2c_test_conn_name"
avx_s2c_conn_type = "unmapped"
remote_gw_type = "generic"
avx_s2c_tunnel_type = "udp"
ha_enabled = "false" # (optional)

avx_gw_name = "avx_gw_name"
avx_gw_name_backup = "avx_backup_gw_name" # (optional)
remote_gw_ip = "5.5.5.5"
pre_shared_key = "key1234" # (optional) Auto-generated if not specified
pre_shared_key_backup = "backupkey5678" # (optional)
remote_subnet_cidr = "10.23.0.0/24" # on-prem's subnet cidr
local_subnet_cidr = "10.20.1.0/24" # (optional)
