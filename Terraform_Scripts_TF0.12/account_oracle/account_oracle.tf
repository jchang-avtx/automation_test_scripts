# Create Aviatrix Oracle account

resource "aviatrix_account" "oci_access_account" {
  cloud_type                    = 16
  account_name                  = "OCIAccess"
  oci_tenancy_id                = var.oci_tenancy_id
  oci_user_id                   = var.oci_user_id
  oci_compartment_id            = var.oci_compartment_id
  oci_api_private_key_filepath  = var.oci_api_private_key
}
