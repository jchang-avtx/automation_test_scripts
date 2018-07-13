output "vgw-tunnel-ip" {
    value = "${module.onprem.aws-vpn-tunnel-ip}"
}
output "onprem-ip" {
    value = "${module.onprem.onprem-private-ip}"
}

#output "vgw-tunnel-key" {
#    value = "${module.onprem.aws-vpn-tunnnel-preshared-key}"
#}
