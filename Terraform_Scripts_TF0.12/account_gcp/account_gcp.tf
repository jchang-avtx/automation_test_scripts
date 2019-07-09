# Create Aviatrix GCP account

resource "aviatrix_account" "gcp_access_account1" {
  account_name                          = var.account_name
  cloud_type                            = 4
  gcloud_project_id                     = var.gcloud_proj_id
  gcloud_project_credentials_filepath   = var.gcloud_proj_cred_filepath
}
