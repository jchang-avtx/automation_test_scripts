terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.13"
}
provider "aviatrix"  {
  controller_ip           = var.aviatrix_controller_ip
  username                = var.aviatrix_controller_username
  password                = var.aviatrix_controller_password
  skip_version_validation = true
}
provider "azurerm" {
  subscription_id         = var.arm_subscription_id
  tenant_id               = var.arm_tenant_id
  client_id               = var.arm_client_id
  client_secret           = var.arm_client_secret

  features {}
}
