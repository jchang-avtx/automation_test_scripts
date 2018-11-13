# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "${var.aviatrix_controller_ip}"
       username = "${var.aviatrix_controller_username}"
       password = "${var.aviatrix_controller_password}"
}

resource "aviatrix_vpn_profile" "terr_profile" {
  name = "profile"
  base_rule = "allow_all"
  policy = [
      {
        action = "allow"
        proto = "tcp" 
        port = "5544"
        target = "10.0.0.0/32"
      },
      {
        action = "allow"
        proto = "tcp" 
        port = "5244"
        target = "11.0.0.0/32"
        }
      ]
  users = []
}
