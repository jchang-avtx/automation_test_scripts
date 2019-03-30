## Creates and manages a FQDN filter for Aviatrix gateway
# must create a GW first before applying FQDN filter

# Create Aviatrix AWS gateway
resource "aviatrix_gateway" "FQDN-GW" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "FQDN-GW"
  vpc_id = "vpc-abcdef"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  vpc_net = "10.0.0.0/24"
  tag_list = ["k1:v1","k2:v2"]
}

resource "aviatrix_gateway" "FQDN-GW2" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "FQDN-GW2"
  vpc_id = "vpc-ghijk"
  vpc_reg = "us-east-1"
  vpc_size = "t2.micro"
  vpc_net = "11.0.0.0/24"
  tag_list = ["k1:v1", "k2:v2"]
}

resource "aviatrix_fqdn" "TAG1" {
      fqdn_tag = "${var.aviatrix_fqdn_tag}"
   fqdn_status = "${var.aviatrix_fqdn_status}"
     fqdn_mode = "${var.aviatrix_fqdn_mode}"
       gw_list = "${var.aviatrix_gateway_list}"
  domain_names = [
                   {
                     fqdn   = "${var.aviatrix_fqdn_domain[0]}"
                     proto  = "${var.aviatrix_fqdn_protocol[0]}"
                     port   = "${var.aviatrix_fqdn_port[0]}"
                   },
                   {
                     fqdn   = "${var.aviatrix_fqdn_domain[1]}"
                     proto  = "${var.aviatrix_fqdn_protocol[1]}"
                     port   = "${var.aviatrix_fqdn_port[1]}"
                   },
                   {
                     fqdn   = "${var.aviatrix_fqdn_domain[2]}"
                     proto  = "${var.aviatrix_fqdn_protocol[2]}"
                     port   = "${var.aviatrix_fqdn_port[2]}"
                   },
                   {
                     fqdn   = "${var.aviatrix_fqdn_domain[3]}"
                     proto  = "${var.aviatrix_fqdn_protocol[3]}"
                     port   = "${var.aviatrix_fqdn_port[3]}"
                   }
                 ]
  depends_on = ["aviatrix_gateway.FQDN-GW", "aviatrix_gateway.FQDN-GW2"]
}
