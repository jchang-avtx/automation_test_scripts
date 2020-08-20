terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
    }
    google = {
      source = "hashicorp/google"
    }
  }
  required_version = ">= 0.13"
}
provider "aviatrix"  {
  controller_ip           = var.aviatrix_controller_ip
  username                = var.aviatrix_controller_username
  password                = var.aviatrix_controller_password
  skip_version_validation = true
}
provider "google" {
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = var.gcp_cloud_region
}
provider "google" {
  alias       = "asia-east1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-east1"
}
provider "google" {
  alias       = "asia-east2"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-east2"
}
provider "google" {
  alias       = "asia-northeast1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-northeast1"
}
provider "google" {
  alias       = "asia-northeast2"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-northeast2"
}
provider "google" {
  alias       = "asia-northeast3"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-northeast3"
}
provider "google" {
  alias       = "asia-south1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-south1"
}
provider "google" {
  alias       = "asia-southeast1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-southeast1"
}
provider "google" {
  alias       = "asia-southeast2"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "asia-southeast2"
}
provider "google" {
  alias       = "australia-southeast1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "australia-southeast1"
}
provider "google" {
  alias       = "europe-north1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "europe-north1"
}
provider "google" {
  alias       = "europe-west1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "europe-west1"
}
provider "google" {
  alias       = "europe-west2"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "europe-west2"
}
provider "google" {
  alias       = "europe-west3"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "europe-west3"
}
provider "google" {
  alias       = "europe-west4"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "europe-west4"
}
provider "google" {
  alias       = "europe-west6"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "europe-west6"
}
provider "google" {
  alias       = "northamerica-northeast1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "northamerica-northeast1"
}
provider "google" {
  alias       = "southamerica-east1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "southamerica-east1"
}
provider "google" {
  alias       = "us-central1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-central1"
}
provider "google" {
  alias       = "us-east1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-east1"
}
provider "google" {
  alias       = "us-east4"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-east4"
}
provider "google" {
  alias       = "us-west1"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-west1"
}
provider "google" {
  alias       = "us-west2"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-west2"
}
provider "google" {
  alias       = "us-west3"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-west3"
}
provider "google" {
  alias       = "us-west4"
  credentials = file(var.gcp_credential_file_location)
  project     = var.gcp_project_name
  region      = "us-west4"
}
