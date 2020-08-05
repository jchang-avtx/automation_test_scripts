##########################
# Outputs
##########################
output "firenet_id" {
  value = aviatrix_firenet.firenet.id
}
output "fqdn_firenet_id" {
  value = aviatrix_firenet.fqdn_firenet.id
}
output "firenet_instance_id" {
  value = aviatrix_firewall_instance.firenet_instance.id
}
output "fqdn_firenet_instance_id" {
  value = aviatrix_firewall_instance.fqdn_firenet_instance.id
}
