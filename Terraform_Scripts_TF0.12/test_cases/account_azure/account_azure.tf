# Create Aviatrix Azure ARM account

resource aviatrix_account azure_access_account_1 {
  account_name         = "azure-access-account1"
  cloud_type           = 8
  arm_subscription_id  = var.arm_sub_id
  arm_directory_id     = var.arm_dir_id
  arm_application_id   = var.arm_app_id
  arm_application_key  = var.arm_app_key
}

output azure_access_account_1_id {
  value = aviatrix_account.azure_access_account_1.id
}
