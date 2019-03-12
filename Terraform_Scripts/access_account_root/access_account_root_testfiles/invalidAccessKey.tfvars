## Test case: test create/ update keys with invalid access key

## NOTE: Please be careful and DO NOT commit personal credentials (ESPECIALLY your access_key and secret_key) into the repo

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

num_account               = 3

cloud_type                = 1
myname                    = "ROOT-access-account"
aws_iam                   = "false"

## Input your credentials here
aws_account_number        = ""

## Key block
aws_access_key = "abc123" # invalid access key (requires all 20 capital alphanumeric characters)
# aws_access_key = "ABCDEFGHIJKLMNOPQRST" # invalid but correctly formatted access key; uncomment to use for Update & invalid input test cases
aws_secret_key            = "" # input valid secret key
