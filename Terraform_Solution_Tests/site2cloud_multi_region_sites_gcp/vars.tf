variable "gcp_cloud_region" {
  default = "us-west1"
}
variable "gcp_site_region" {
  type = list(string)
}

variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_gcp_access_account" {}

variable "gcp_credential_file_location" {}
variable "gcp_project_name" {}

variable "ssh_user" {}
variable "public_key" {}
variable "private_key" {}

variable "pre_shared_key" {}
variable "phase_1_authentication" {}
variable "phase_2_authentication" {}
variable "phase_1_dh_groups" {}
variable "phase_2_dh_groups" {}
variable "phase_1_encryption" {}
variable "phase_2_encryption" {}
