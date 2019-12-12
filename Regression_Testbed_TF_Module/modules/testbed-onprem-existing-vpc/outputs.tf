output "onprem_aviatrix_gw_info" {
  value = [
    aviatrix_gateway.avtx_gw.gw_name,
    aviatrix_gateway.avtx_gw.cloud_instance_id,
    aviatrix_gateway.avtx_gw.subnet
  ]
}

output "onprem_vgw_info" {
  value = [
    aws_vpn_gateway.aws_vgw.tags.Name,
    aws_vpn_gateway.aws_vgw.id
  ]
}

output "onprem_cgw_info" {
  value = [
    aws_customer_gateway.aws_cgw.tags.Name,
    aws_customer_gateway.aws_cgw.id
  ]
}

output "onprem_vpn_info" {
  value = [
    aws_vpn_connection.vpn.tags.Name,
    aws_vpn_connection.vpn.id
  ]
}

output "onprem_s2c_info" {
  value = [
    aviatrix_site2cloud.onprem_s2c.connection_name,
    aviatrix_site2cloud.onprem_s2c.remote_subnet_cidr
  ]
}
