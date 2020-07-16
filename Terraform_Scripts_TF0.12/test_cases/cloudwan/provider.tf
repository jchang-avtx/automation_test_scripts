provider "aws" {
  region = "us-east-2"
}

provider "aviatrix" {
  skip_version_validation = true
}
