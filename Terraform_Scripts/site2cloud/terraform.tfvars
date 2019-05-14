# initial creation

##############################################

aws_vpc_id = "vpc-abcd1234"
avx_s2c_conn_name = "s2c_test_conn_name"
avx_s2c_conn_type = "unmapped"
remote_gw_type = "generic"
avx_s2c_tunnel_type = "udp"
ha_enabled = "no" # (optional)

avx_gw_name = "avxPrimaryGwName"
# avx_gw_name_backup = "avxPrimaryGwName" # uncomment before creation to test s2c ha_enabled = "yes"
remote_gw_ip = "5.5.5.5"
# remote_gw_ip_backup = "4.4.4.4" # uncomment before creation to test s2c ha_enabled = "yes"
# pre_shared_key = "key1234" # (optional) Auto-generated if not specified
# pre_shared_key_backup = "backupkey5678" # (optional)
remote_subnet_cidr = "10.23.0.0/24" # on-prem's subnet cidr
local_subnet_cidr = "10.20.1.0/24" # (optional)
