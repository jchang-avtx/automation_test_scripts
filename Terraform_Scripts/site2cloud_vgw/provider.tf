provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region1}"
}

# Edit to enter your controller's IP, username and password to login with.
provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
  username = "${var.controller_username}"
  password = "${var.controller_password}"
}

