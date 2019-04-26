# Create Aviatrix Controller Config
resource "aviatrix_controller_config" "test_controller_config" {
  http_access                = true # default: false
  fqdn_exception_rule        = false # default: true
  sg_management_account_name = "username" # optional cloud account name of user
  security_group_management  = true # default: false; use to manage Controller instance's inbound rules from gws 
}
