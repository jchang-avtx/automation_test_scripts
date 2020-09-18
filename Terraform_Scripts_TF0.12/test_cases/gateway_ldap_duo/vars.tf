variable aviatrix_vpn_duo_integration_key {}
variable aviatrix_vpn_duo_secret_key {}
variable aviatrix_vpn_duo_api_hostname {}
variable aviatrix_vpn_duo_push_mode {}

variable aviatrix_vpn_ldap_server {}
variable aviatrix_vpn_ldap_bind_dn {}
variable aviatrix_vpn_ldap_password {}
variable aviatrix_vpn_ldap_base_dn {}
variable aviatrix_vpn_ldap_username_attribute {}

variable enable_gov {
  type = bool
  default = false
  description = "Enable to create AWS GovCloud test case"
}
