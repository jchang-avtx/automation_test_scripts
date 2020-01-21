# Create Aviatrix Controller Config

resource "aviatrix_controller_config" "test_controller_config" {
  http_access                = var.toggle_http_access
  fqdn_exception_rule        = var.toggle_fqdn_exception
  sg_management_account_name = var.sg_account_name
  security_group_management  = var.toggle_sg_management
  target_version             = "latest" # added in 4.7 ; if not specified, will not upgrade/ matches computed version
}

output "test_controller_config_id" {
  value = aviatrix_controller_config.test_controller_config.id
}
