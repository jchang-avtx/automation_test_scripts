# Create Aviatrix gateway in AWS public cloud

resource "aviatrix_fqdn" "TAG1" {
      fqdn_tag = "${var.aviatrix_fqdn_tag}"
   fqdn_status = "${var.aviatrix_fqdn_status}"
     fqdn_mode = "${var.aviatrix_fqdn_mode}"
       gw_list = "${var.aviatrix_gateway_list}"
  domain_names = [
                   {
                     fqdn = "${var.aviatrix_fqdn_domain[0]}"
                     proto= "${var.aviatrix_fqdn_protocol[0]}"
                     port = "${var.aviatrix_fqdn_port[0]}"
                   },
                   {
                     fqdn = "${var.aviatrix_fqdn_domain[1]}"
                     proto= "${var.aviatrix_fqdn_protocol[1]}"
                     port = "${var.aviatrix_fqdn_port[1]}"
                   },
                   {
                     fqdn = "${var.aviatrix_fqdn_domain[2]}"
                     proto= "${var.aviatrix_fqdn_protocol[2]}"
                     port = "${var.aviatrix_fqdn_port[2]}"
                   },
                   {
                     fqdn = "${var.aviatrix_fqdn_domain[3]}"
                     proto= "${var.aviatrix_fqdn_protocol[3]}"
                     port = "${var.aviatrix_fqdn_port[3]}"
                   }
                 ]
}

# resource "aviatrix_fqdn" "TAG1" {
#       fqdn_tag = "${var.aviatrix_fqdn_tag}"
#    fqdn_status = "${var.aviatrix_fqdn_status}"
#      fqdn_mode = "${var.aviatrix_fqdn_mode}"
#        gw_list = "${var.aviatrix_gateway_list}"
#   domain_names = [
#                    {
#                      fqdn = "facebook.com"
#                      proto= "tcp"
#                      port = "443"
#                    },
#                    {
#                      fqdn = "google.com"
#                      proto= "udp"
#                      port = "480"
#                    },
#                    {
#                      fqdn = "twitter.com"
#                      proto= "udp"
#                      port = "480"
#                    },
#                    {
#                      fqdn = "cnn.com"
#                      proto= "udp"
#                      port = "480"
#                    }
#                  ]
# }
