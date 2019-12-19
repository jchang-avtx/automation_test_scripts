provider "aviatrix"  {
  controller_ip = var.aviatrix_controller_ip
  username      = var.aviatrix_controller_username
  password      = var.aviatrix_controller_password
}

provider "aws" {
  region = "us-east-2"
}

provider "azurerm" {}
