## Create Aviatrix User Account

# username is the name of the account user to be created
# account_name is name of the cloud account that the user will be created under
resource "aviatrix_account_user" "test_accountuser" {
  username      = "${var.aviatrix_account_username}"
  account_name  = "${var.aviatrix_cloud_account_name}"
  email         = "${var.aviatrix_account_user_email}"
  password      = "${var.aviatrix_account_user_password}"
}
