# Edit to enter your controller's IP, username and password to login with.
provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
  username = "${var.controller_username}"
  password = "${var.controller_password}"
}

