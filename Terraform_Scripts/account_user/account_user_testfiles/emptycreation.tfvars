# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis: id=8240 for issue with reported refresh, update and REST-API issues
## This file is also used to test Update test case;; See sections for Valid Input

## Additional test cases:
## - account_user can now be imported
## - does not support update <to be discussed>

##############################################
## VALID INPUT
##############################################

aviatrix_account_username       = "username1"
aviatrix_cloud_account_name     = "AccessAccountName" # or read_only, admin
aviatrix_account_user_email     = "username1@example.com"
aviatrix_account_user_password  = "Password1!"

## update test case
# aviatrix_account_username = "changedUser" # should not work; EDIT: not supported by TF
# aviatrix_cloud_account_name = "changedAccountName" # should not work
# aviatrix_account_user_email = "changedEmail@example.com" # should work
# aviatrix_account_user_email = "notanemail@nodotcom" # EDIT: accepted b/c x@y is acceptable email
# aviatrix_account_user_password = "changedPassword1!" # should work; EDIT: fails; no changes in GUI

##############################################
## INVALID / EMPTY INPUT
##############################################

## empty
aviatrix_account_username = "" # correctly requires a username
aviatrix_cloud_account_name = "" # correctly requires account name
aviatrix_account_user_email = "" # optional; theoretically should work and default to no email; EDIT: requires email
aviatrix_account_user_password = "" # optional; theoretically should work and default to no password; EDIT: requires pass

## invalid
# aviatrix_account_username = "!?!" # IGNORE THIS; apparently this is acceptable name
# aviatrix_cloud_account_name = "invalidAccountName" # correctly detects does not exist
# aviatrix_account_user_email = "notanemail" # correctly fails because not correct email format
# aviatrix_account_user_password = "password1" # invalid because of weak password requirement; should catch and not create/edit/ruin state
