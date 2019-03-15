## empty creations

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty + valid input
## Please see Mantis: id=8328 for reported refresh, update, and REST-API issues

## NOTE: Please be careful and DO NOT commit personal credentials (ESPECIALLY your access_key and secret_key) into the repo

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT
##############################################
## Do not edit num_account
num_account               = 3
##############################################
# cloud_type                = 1
# myname                    = "ROOT-access-account"
# aws_iam                   = "false"
#
# ## Input your credentials here
# aws_account_number        = ""
#
# ## Key block (input valid keys)
# aws_access_key            = ""
# aws_secret_key            = ""


##############################################
## EMPTY/ INVALID INPUT (due to formatting)
##############################################
cloud_type = ""
myname = "" # blank name works because of access_account_root.tf defaulting with count variable
aws_iam = "" # empty.
aws_account_number = ""

aws_access_key = ""
aws_secret_key = ""
