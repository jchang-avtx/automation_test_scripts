# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinatinos of empty/invalid + valid input
## See Mantis: id = 8002

## These credentials must be filled to test
aviatrix_controller_ip  = "1.2.3.4"
aviatrix_account_username  = "admin"
aviatrix_account_password  = "password"

## VALID INPUTS
   aviatrix_fqdn_mode   = "white"
 aviatrix_fqdn_status   = "enabled"
    aviatrix_fqdn_tag   = "user-fqdn-TAG3.4"
aviatrix_gateway_list   = ["FQDN-GW"]

aviatrix_fqdn_domain          = ["facebook.com", "google.com", "twitter.com", "cnn.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "udp", "udp"]
aviatrix_fqdn_port            = ["443", "480", "480", "480"]

##############################################
# EMPTY / INVALID INPUT
# aviatrix_fqdn_mode   = ""
# aviatrix_fqdn_status   = ""
 # aviatrix_fqdn_tag   = ""
# aviatrix_gateway_list   = []
#
# aviatrix_fqdn_domain          = ["", "", "", ""]
# aviatrix_fqdn_protocol        = ["", "", "", ""]
# aviatrix_fqdn_port            = ["", "", "", ""]
