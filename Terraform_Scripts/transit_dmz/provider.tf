provider "aws" {
  alias      = "ca-central-1"
  region     = "${var.single_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
  username = "${var.controller_username}"
  password = "${var.controller_password}"
}

