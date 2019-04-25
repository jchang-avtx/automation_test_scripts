# Create Aviatrix Azure ARM account
# resource "aviatrix_account" "azure_access_account1" {
#   account_name = "AzureAccess"
#   cloud_type = 8
#   arm_subscription_id  =  "abcd1234-5678-9012-defg-hijk1234mnop"
#   arm_directory_id     =  "director-yarm-id12-3456-abcd1234hijk"
#   arm_application_id   =  "armappl-icat-ionI-D123-456789012345"
#   arm_application_key  =  "/AbCdEfGh/arm_application_key1234/HIJK1234="
# }

## Update test for App ID and Key
# Create Aviatrix Azure ARM account
resource "aviatrix_account" "azure_access_account1" {
  account_name = "AzureAccess"
  cloud_type = 8
  arm_subscription_id  =  "abcd1234-5678-9012-defg-hijk1234mnop"
  arm_directory_id     =  "director-yarm-id12-3456-abcd1234hijk"
  arm_application_id   =  "NEWappl-icat-ionI-D123-456789012345" ## updated App ID
  arm_application_key  =  "/NeW_+123/arm_application_key1234/abcd1234=" ## updated App key
}
