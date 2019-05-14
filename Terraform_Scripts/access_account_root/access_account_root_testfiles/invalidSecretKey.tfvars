## Test case: Create/ update with invalid secret key

## NOTE: Please be careful and DO NOT commit personal credentials (ESPECIALLY your access_key and secret_key) into the repo

##############################################

num_account               = 3

cloud_type                = 1
myname                    = "ROOT-access-account"
aws_iam                   = "false"

## Input your credentials here
aws_account_number        = ""

## Key block
aws_access_key            = "" # input valid access key
aws_secret_key = "invalidSecretKey" # invalid secret key (requires 40 alphanumeric, plus sign and slash char)
# aws_secret_key = "abcDEFghiJKLmnoPQRstuVWXyz12345678901112" # invalid but correctly formatted secret key; uncomment to use for Update test case
