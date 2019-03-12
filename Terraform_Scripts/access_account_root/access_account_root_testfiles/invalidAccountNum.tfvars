## Test case: Create/ update invalid aws account number

## NOTE: Please be careful and DO NOT commit personal credentials (ESPECIALLY your access_key and secret_key) into the repo

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

num_account               = 3

cloud_type                = 1
myname                    = "ROOT-access-account"
aws_iam                   = "false"

## Test these 2 lines (17-18)
aws_account_number = "1234" # invalid account number (requires 12 digit format)
# aws_account_number = "123456789012" # invalid but correctly formatted account #; uncomment to use for Update & invalid input test cases

## Key block (Input valid keys)
aws_access_key            = ""
aws_secret_key            = ""
