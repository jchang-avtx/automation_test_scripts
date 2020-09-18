# Create Aviatrix AWS SAML Endpoint

resource "aviatrix_saml_endpoint" "text_saml_endpoint" {
  endpoint_name         = "text_saml_endpoint"
  idp_metadata_type     = "Text"
  idp_metadata          = "sample saml text heree"
  # custom_entity_id      = "customID" # blank if Hostname. Otherwise, set custom ID here
}

resource "aviatrix_saml_endpoint" "custom_saml_endpoint" {
  endpoint_name         = "custom_saml_endpoint"
  idp_metadata_type     = "Text"
  idp_metadata          = "sample saml text part 2"
  custom_entity_id      = "customID"
  custom_saml_request_template = base64decode(var.saml_template)
}

resource "aviatrix_saml_endpoint" "text_login_endpoint" {
  endpoint_name         = "text_login_endpoint"
  idp_metadata_type     = "Text"
  idp_metadata          = "sample saml text part 3"
  custom_saml_request_template = base64decode(var.saml_template)

  controller_login    = true
  access_set_by       = "profile_attribute" # controller / profile_attribute
}

resource "aviatrix_saml_endpoint" "custom_login_endpoint" {
  endpoint_name         = "custom_login_endpoint"
  idp_metadata_type     = "Text"
  idp_metadata          = "sample saml text part 4"
  custom_entity_id      = "customID2"
  custom_saml_request_template = base64decode(var.saml_template)

  controller_login    = true
  access_set_by       = "controller" # controller / profile_attribute
  rbac_groups         = ["admin", "read_only"] # admin / read_only
}

output "text_saml_endpoint_id" {
  value = aviatrix_saml_endpoint.text_saml_endpoint.id
}

output "custom_saml_endpoint_id" {
  value = aviatrix_saml_endpoint.custom_saml_endpoint.id
}

output "text_login_endpoint_id" {
  value = aviatrix_saml_endpoint.text_login_endpoint.id
}

output "custom_login_endpoint_id" {
  value = aviatrix_saml_endpoint.custom_login_endpoint.id
}
