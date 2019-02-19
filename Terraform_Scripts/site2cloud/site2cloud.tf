## Creates and manages an Aviatrix Site2Cloud connection

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
}
