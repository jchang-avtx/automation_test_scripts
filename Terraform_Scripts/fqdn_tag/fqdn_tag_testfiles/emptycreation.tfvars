# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinatinos of empty/invalid + valid input
## See Mantis: id = 8002

## Additional test cases:
## - empty/ invalid gateway with valid/ invalid/ empty domain_names
## - protocol icmp with non-blank port / non 0:65535

## These credentials must be filled to test
aviatrix_controller_ip  = "1.2.3.4"
aviatrix_account_username  = "admin"
aviatrix_account_password  = "password"

##############################################
## VALID INPUTS
##############################################
#    aviatrix_fqdn_mode   = "white"
#  aviatrix_fqdn_status   = "enabled"
#     aviatrix_fqdn_tag   = "user-fqdn-TAG"
# aviatrix_gateway_list   = ["FQDN-GW"]
#
# aviatrix_fqdn_domain          = ["facebook.com", "google.com", "twitter.com", "cnn.com"]
# aviatrix_fqdn_protocol        = ["tcp", "udp", "udp", "udp"]
# aviatrix_fqdn_port            = ["443", "480", "480", "480"]

##############################################
## EMPTY / INVALID INPUT
##############################################
aviatrix_fqdn_mode      = ""
aviatrix_fqdn_status    = ""
aviatrix_fqdn_tag       = ""
aviatrix_gateway_list   = [] # empty list;; is valid because (optional)
# aviatrix_gateway_list   = [""] # list with gw name "" ;; is valid because (optional)
# aviatrix_gateway_list   = ["notCorrectGWName"]

## empty (these will not create; but empty FQDN filter will)
aviatrix_fqdn_domain          = ["", "", "", ""]
aviatrix_fqdn_protocol        = ["", "", "", ""]
aviatrix_fqdn_port            = ["", "", "", ""]

## invalid (these will not create; but empty FQDN filter will)
# aviatrix_fqdn_domain          = ["notaDomain", true, "1234", 1]
# aviatrix_fqdn_protocol        = ["notaValidProtocol", true, "123", 2]
# aviatrix_fqdn_port            = ["notaPort", false, "!!", 3]
