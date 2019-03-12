## Test case: Create/ update invalid IAM chocie

## NOTE: Please be careful and DO NOT commit personal credentials (ESPECIALLY your access_key and secret_key) into the repo

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

num_account               = 3

cloud_type                = 1
myname                    = "ROOT-access-account"
# aws_iam = "invalidBoolean" # SHOULD accept boolean, so string type should fail; it is now a string type req?!

## Input your credentials here
aws_account_number        = ""

## Key block (input valid keys)
aws_access_key            = ""
aws_secret_key            = ""
