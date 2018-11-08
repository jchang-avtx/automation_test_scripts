output "aws-vpn-tunnel-ip" {
    value = ["${aws_vpn_connection.onprem.tunnel1_address}","${aws_vpn_connection.onprem.tunnel2_address}"]
}
output "onprem-public-ip" {
    value = "${aviatrix_gateway.OnPrem-GW.public_ip}"
}
