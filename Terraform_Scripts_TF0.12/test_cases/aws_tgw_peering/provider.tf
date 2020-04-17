provider "aviatrix" {skip_version_validation = true}

provider "aws" {
	region = "eu-central-1"
}

provider "aws" {
	alias = "us-east-1"
	region = "us-east-1"
}
