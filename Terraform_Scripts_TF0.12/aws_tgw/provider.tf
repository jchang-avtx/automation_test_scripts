provider "aviatrix"  {
  controller_ip = var.aviatrix_controller_ip
  username      = var.aviatrix_controller_username
  password      = var.aviatrix_controller_password
}

provider "aws" {
  region = "eu-central-1"
}
