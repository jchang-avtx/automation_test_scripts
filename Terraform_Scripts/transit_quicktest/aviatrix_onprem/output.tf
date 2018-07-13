output "aws-vpn-tunnel-ip" {
    value = ["${aws_vpn_connection.onprem.tunnel1_address}","${aws_vpn_connection.onprem.tunnel2_address}"]
}
output "onprem-private-ip" {
    value = "${aviatrix_gateway.OnPrem-GW.public_ip}"
}

#output "aws-vpn-tunnel-preshared-key" {
#    value = ["${aws_vpn_connection.onprem.tunnel2_preshared_key}","${aws_vpn_connection.onprem.tunnel2_preshared_key}"]
#}
