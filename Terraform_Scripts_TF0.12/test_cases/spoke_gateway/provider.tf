provider "aviatrix" {skip_version_validation = true}

provider "aws" {
  region = var.enable_gov ? "us-gov-east-1" : "us-east-1"
}
