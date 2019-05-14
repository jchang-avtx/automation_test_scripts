# variable "aviatrix_controller_ip" {}
# variable "aviatrix_controller_username" {}
# variable "aviatrix_controller_password" {}

variable "aws_vpc_id" {}

variable "avx_s2c_conn_name" {}
variable "avx_s2c_conn_type" {}
variable "avx_s2c_tunnel_type" {}

variable "avx_gw_name" {}
# variable "avx_gw_name_backup" {} # uncomment before creation to test s2c ha_enabled = "yes"

variable "remote_gw_type" {}
variable "remote_gw_ip" {}
# variable "remote_gw_ip_backup" {} # uncomment before creation to test s2c ha_enabled = "yes"
variable "remote_subnet_cidr" {}
variable "local_subnet_cidr" {}

variable "ha_enabled" {}

# variable "pre_shared_key" {}
# variable "pre_shared_key_backup" {}
