variable "arm_cloud_region" {
  default = "West US"
}
variable "arm_site_region" {
  type = list(string)
}

variable "arm_subscription_id" {}
variable "arm_tenant_id" {}
variable "arm_client_id" {}
variable "arm_client_secret" {}

variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}
variable "aviatrix_arm_access_account" {}

variable "ssh_user" {
  default = "azureuser"
}
variable "public_key" {}
variable "private_key" {}

variable "pre_shared_key" {}
variable "phase_1_authentication" {}
variable "phase_2_authentication" {}
variable "phase_1_dh_groups" {}
variable "phase_2_dh_groups" {}
variable "phase_1_encryption" {}
variable "phase_2_encryption" {}
