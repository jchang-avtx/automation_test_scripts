## Creates and manages a FQDN filter for Aviatrix gateway

resource "aviatrix_gateway" "FQDN-GW" {
  cloud_type    = 1
  account_name  = "AnthonyPrimaryAccess"
  gw_name       = "FQDN-GW"
  vpc_id        = "vpc-0086065966b807866"
  vpc_reg       = "us-east-1"
  gw_size       = "t2.micro"
  subnet        = "10.0.0.0/24"
  enable_snat   = true
}

resource "aviatrix_gateway" "FQDN-GW2" {
  cloud_type    = 1
  account_name  = "AnthonyPrimaryAccess"
  gw_name       = "FQDN-GW2"
  vpc_id        = "vpc-04ca29a568bf2b35f"
  vpc_reg       = "us-east-1"
  gw_size       = "t2.micro"
  subnet        = "10.202.0.0/16"
  enable_snat   = true
}

resource "aviatrix_fqdn" "FQDN-tag1" {
  fqdn_tag      = var.aviatrix_fqdn_tag
  fqdn_enabled  = var.aviatrix_fqdn_status
  fqdn_mode     = var.aviatrix_fqdn_mode

  gw_filter_tag_list {
    gw_name         = var.aviatrix_fqdn_gateway
    source_ip_list  = var.aviatrix_fqdn_source_ip_list
  }

  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[0]
    proto  = var.aviatrix_fqdn_protocol[0]
    port   = var.aviatrix_fqdn_port[0]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[1]
    proto  = var.aviatrix_fqdn_protocol[1]
    port   = var.aviatrix_fqdn_port[1]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[2]
    proto  = var.aviatrix_fqdn_protocol[2]
    port   = var.aviatrix_fqdn_port[2]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[3]
    proto  = var.aviatrix_fqdn_protocol[3]
    port   = var.aviatrix_fqdn_port[3]
  }

  depends_on = ["aviatrix_gateway.FQDN-GW", "aviatrix_gateway.FQDN-GW2"]
}
