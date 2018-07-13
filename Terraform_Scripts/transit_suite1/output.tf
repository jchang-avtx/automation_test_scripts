output "vgw-tunnel-ip" {
    value = "${module.onprem.aws-vpn-tunnel-ip}"
}
output "onprem-publicIP" {
    value = "${module.onprem.onprem-public-ip}"
}
##output "onprem-privateIP" {
#    value = "${module.onprem.onprem-private-ip}"
#}
#output "spoke-privateIP" {
#    value = "${module.spoke.spoke-private-ip}"
#}
#output "spoke-publicIP" {
#    value = "${module.spoke.spoke-public-ip}"
#}
#output "shared-privateIP" {
#    value = "${module.spoke.spoke-private-ip}"
#}
#output "shared-publicIP" {
#    value = "${module.spoke.spoke-public-ip}"
#}
