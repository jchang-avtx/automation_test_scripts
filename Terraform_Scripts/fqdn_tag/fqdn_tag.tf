# Create Aviatrix gateway in AWS public cloud 

resource "aviatrix_fqdn" "TAG1" {
      fqdn_tag = "${var.aviatrix_fqdn_tag}"
   fqdn_status = "${var.aviatrix_fqdn_status}"
     fqdn_mode = "${var.aviatrix_fqdn_mode}"
       gw_list = "${var.aviatrix_gateway_list}"
  domain_names = [
                   {
                     fqdn = "facebook.com"
                     proto= "tcp"
                     port = "443"
                   },
                   {
                     fqdn = "google.com"
                     proto= "udp"
                     port = "480"
                   },
                   {
                     fqdn = "twitter.com"
                     proto= "udp"
                     port = "480"
                   },
                   {
                     fqdn = "cnn.com"
                     proto= "udp"
                     port = "480"
                   }
                 ]
}
