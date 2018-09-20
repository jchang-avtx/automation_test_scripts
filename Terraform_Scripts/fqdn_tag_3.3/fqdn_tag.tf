# Create Aviatrix gateway in AWS public cloud 

resource "aviatrix_fqdn" "TAG1" {
      fqdn_tag = "${var.aviatrix_fqdn_tag}"
   fqdn_status = "${var.aviatrix_fqdn_status}"
     fqdn_mode = "${var.aviatrix_fqdn_mode}"
       gw_list = "${var.aviatrix_gateway_list}"
   domain_list = "${var.aviatrix_domain_list}"
}
