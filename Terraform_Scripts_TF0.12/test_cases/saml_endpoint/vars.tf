variable saml_template {}

variable text_saml_idp_meta {
  default = "sample saml text heree"
}

variable custom_saml_entity_id {
  default = "customID"
}

variable custom_login_access_set {
  default = "profile_attribute"
}
variable custom_login_rbac_groups {
  default = ["admin", "read_only"]
}
