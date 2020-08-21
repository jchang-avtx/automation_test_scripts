# Outputs for ARM Client module

output "ubuntu_public_ip" {
  value = azurerm_public_ip.public_ip[*].ip_address
}

output "ubuntu_private_ip" {
  value = azurerm_network_interface.main[*].private_ip_address
}

output "ubuntu_instance_id" {
  value = azurerm_virtual_machine.client[*].id
}
