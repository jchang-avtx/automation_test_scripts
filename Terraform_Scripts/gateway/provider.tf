# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "${var.aviatrix_controller_ip}"
       username = "${var.aviatrix_controller_username}"
       password = "${var.aviatrix_controller_password}"
}
