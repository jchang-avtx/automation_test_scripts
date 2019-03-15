## Test case: Create/ update invalid cloud type

## NOTE: Please be careful and DO NOT commit personal credentials (ESPECIALLY your access_key and secret_key) into the repo

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

num_account               = 3

cloud_type = 123455677 # this is invalid input; currently only AWS (1) is supported
myname                    = "ROOT-access-account"
aws_iam                   = "false"

## Input your credentials here
aws_account_number        = ""

## Key block (input valid keys)
aws_access_key            = ""
aws_secret_key            = ""
