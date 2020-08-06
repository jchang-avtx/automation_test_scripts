## Create Aviatrix User Account

resource aviatrix_account_user test_accountuser {
  username        = var.aviatrix_account_username
  # account_name    = var.aviatrix_cloud_account_name
  email           = var.aviatrix_account_user_email
  password        = var.aviatrix_account_user_password

  lifecycle {
    ignore_changes = [password]
  }
}

output test_accountuser_id {
  value = aviatrix_account_user.test_accountuser.id
}
