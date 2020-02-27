## Creates and manages a FQDN filter for Aviatrix gateway

resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "aviatrix_vpc" "fqdn_vpc_1" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "fqdn-vpc-1"
  region                = "us-east-1"
}

resource "aviatrix_vpc" "fqdn_vpc_2" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "fqdn-vpc-2"
  region                = "us-east-1"
}

resource "aviatrix_gateway" "fqdn_gw_1" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "fqdn-gw-1"
  vpc_id        = aviatrix_vpc.fqdn_vpc_1.vpc_id
  vpc_reg       = aviatrix_vpc.fqdn_vpc_1.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.fqdn_vpc_1.subnets.6.cidr
  single_ip_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

resource "aviatrix_gateway" "fqdn_gw_2" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "fqdn-gw-2"
  vpc_id        = aviatrix_vpc.fqdn_vpc_2.vpc_id
  vpc_reg       = aviatrix_vpc.fqdn_vpc_2.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.fqdn_vpc_2.subnets.6.cidr
  single_ip_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

resource "aviatrix_fqdn" "fqdn_tag_1" {
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

  depends_on = [aviatrix_gateway.fqdn_gw_1, aviatrix_gateway.fqdn_gw_2]
}

output "fqdn_tag_1_id" {
  value = aviatrix_fqdn.fqdn_tag_1.id
}
