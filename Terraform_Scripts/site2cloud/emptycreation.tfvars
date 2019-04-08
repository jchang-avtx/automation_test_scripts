# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of emptyinvalid + valid input
## Please see id=8509 for issues with refresh, Update, empty/invalid

# input your Avx controller credentials here
aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT
##############################################
# aws_vpc_id = "vpc-abcd1234"
# avx_s2c_conn_name = "s2c_test_conn_name"
# avx_s2c_conn_type = "unmapped"
# remote_gw_type = "generic"
# avx_s2c_tunnel_type = "udp"
# ha_enabled = "false" # (optional)
#
# avx_gw_name = "avxPrimaryGwName"
# # avx_gw_name_backup = "avxPrimaryGwName" # (optional)
# remote_gw_ip = "5.5.5.5"
# # remote_gw_ip_backup = "4.4.4.4"
# pre_shared_key = "key1234" # (optional) Auto-generated if not specified
# # pre_shared_key_backup = "backupkey5678" # (optional)
# remote_subnet_cidr = "10.23.0.0/24" # on-prem's subnet cidr
# local_subnet_cidr = "10.20.1.0/24" # (optional)


##############################################
## INVALID/ EMPTY INPUT
##############################################
aws_vpc_id = ""
avx_s2c_conn_name = ""
avx_s2c_conn_type = "" # "mapped" or "unmapped"
remote_gw_type = "" # "generic", "avx", "aws", "azure", "sonicwall"
avx_s2c_tunnel_type = "" # udp or tcp
ha_enabled = "invalidBoolean" # (Optional) "true" or "false"

avx_gw_name = ""
avx_gw_name_backup = "nonexistant-hagw" # (Optional)
remote_gw_ip = "" # avtxgw2
# remote_gw_ip = "invalidIP"
remote_gw_ip_backup = "" # avtxgw2-backup
# remote_gw_ip_backup = "invalidIP"
# pre_shared_key = "" # (optional) Auto-generated if not specified;; not testable
# pre_shared_key_backup = "" # (Optional) ;; not testable
remote_subnet_cidr = "" # on-prem's subnet cidr
# remote_subnet_cidr = "invalidCIDR"
local_subnet_cidr = "" # (optional)
# local_subnet_cidr = "invalidCIDR"
