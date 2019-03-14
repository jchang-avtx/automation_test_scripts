provider "aws" {
  alias      = "ca-central-1"
  region     = "${var.single_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "aviatrix" {
  controller_ip = "${var.aviatrix_controller_ip}"
  username      = "${var.aviatrix_controller_username}"
  password      = "${var.aviatrix_controller_password}"
}

