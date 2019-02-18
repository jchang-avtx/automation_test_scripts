## Use to get Aviatrix gw info for use in other resources
## Be sure to use in same directory with provider.tf and/or init terraform there as well

# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "1.2.3.4"
       username = "admin"
       password = "password"
}

data "aviatrix_gateway" "testGW1" {
  account_name = "Aviatrix_Account_Name" # (Optional) Aviatrix acc name
  gw_name = "Aviatrix_Gateway_Name" # (Required) Aviatrix gateway name
}
