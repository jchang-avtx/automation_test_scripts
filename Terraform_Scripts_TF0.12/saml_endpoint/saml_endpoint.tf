# Create Aviatrix AWS SAML Endpoint

resource "aviatrix_saml_endpoint" "text_saml_endpoint" {
  endpoint_name         = "text_saml_endpoint"
  idp_metadata_type     = "Text"
  idp_metadata          = "sample saml text heree"
  # custom_entity_id      = "customID" # blank if Hostname. Otherwise, set custom ID here
}
