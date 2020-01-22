# Create Aviatrix GCP account

resource "aviatrix_account" "gcp_access_account_1" {
  account_name                          = "gcp-access-account-1"
  cloud_type                            = 4
  gcloud_project_id                     = var.gcloud_proj_id
  gcloud_project_credentials_filepath   = var.gcloud_proj_cred_filepath
}

output "gcp_access_account_1_id" {
  value = aviatrix_account.gcp_access_account_1.id
}
