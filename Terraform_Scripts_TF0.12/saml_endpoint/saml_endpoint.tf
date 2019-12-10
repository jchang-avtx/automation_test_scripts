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
  custom_saml_request_template = "${base64decode(var.saml_template)}"
}

output "text_saml_endpoint_id" {
  value = aviatrix_saml_endpoint.text_saml_endpoint.id
}

output "custom_saml_endpoint_id" {
  value = aviatrix_saml_endpoint.custom_saml_endpoint.id
}
