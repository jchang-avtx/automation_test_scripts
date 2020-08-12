provider "aviatrix"  {
  controller_ip           = var.aviatrix_controller_ip
  username                = var.aviatrix_controller_username
  password                = var.aviatrix_controller_password
  skip_version_validation = true
}
provider "aws" {
  region     = var.aws_cloud_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "us-east-1"
  alias      = "NorthVirginia"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "us-east-2"
  alias      = "Ohio"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "us-west-1"
  alias      = "NorthCalifornia"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "us-west-2"
  alias      = "Oregon"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "af-south-1"
  alias      = "CapeTown"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ap-east-1"
  alias      = "HongKong"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ap-south-1"
  alias      = "Mumbai"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ap-northeast-2"
  alias      = "Seoul"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ap-southeast-1"
  alias      = "Singapore"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ap-southeast-2"
  alias      = "Sydney"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ap-northeast-1"
  alias      = "Tokyo"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "ca-central-1"
  alias      = "Canada"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "eu-central-1"
  alias      = "Frankfurt"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "eu-west-1"
  alias      = "Ireland"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "eu-west-2"
  alias      = "London"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "eu-south-1"
  alias      = "Milan"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "eu-west-3"
  alias      = "Paris"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "eu-north-1"
  alias      = "Stockholm"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "me-south-1"
  alias      = "Bahrain"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region     = "sa-east-1"
  alias      = "SaoPaulo"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
