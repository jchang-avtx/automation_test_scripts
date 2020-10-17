terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aviatrix"  {
  controller_ip = var.aviatrix_controller_ip
  username      = var.aviatrix_controller_username
  password      = var.aviatrix_controller_password
  skip_version_validation = true
}
