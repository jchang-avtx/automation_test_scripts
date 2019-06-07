# Create Aviatrix Controller Config
resource "aviatrix_controller_config" "test_controller_config" {
  http_access                = "${var.toggle_http_access}" # default: false
  fqdn_exception_rule        = "${var.toggle_fqdn_exception}" # default: true
  sg_management_account_name = "${var.sg_account_name}" # optional cloud account name of user
  security_group_management  = "${var.toggle_sg_management}" # default: false ; use to manage Controller instance's inbound rules from gws
  target_version             = "latest" # added in 4.7 ; if not specified, will not upgrade
}
