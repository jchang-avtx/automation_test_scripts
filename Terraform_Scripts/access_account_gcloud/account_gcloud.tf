# # Create Aviatrix GCP account
# resource "aviatrix_account" "tempacc_gcp" {
#   account_name = "GCPAccess"
#   cloud_type = 4
#   gcloud_project_id = "aviatrix-testing-123456"
#   gcloud_project_credentials_filepath = "/some/path/tothefile/gcloud_project.json"
# }

## Update test for projectID and credentials
# Create Aviatrix GCP account
resource "aviatrix_account" "tempacc_gcp" {
  account_name = "GCPAccess"
  cloud_type = 4
  gcloud_project_id = "new-gcloud-project-id" ## updated gcloud_project_id
  gcloud_project_credentials_filepath = "new-gcloud-project-id.json" ## updated gcloud_credentials_filepath (file)
}
