## Creates and manages a FQDN filter for Aviatrix gateway

resource random_integer vpc1_cidr_int {
  count = 3
  min = 1
  max = 126
}

resource random_integer vpc2_cidr_int {
  count = 3
  min = 1
  max = 126
}

resource aviatrix_vpc fqdn_vpc_1 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "fqdn-vpc-1"
  region                = "us-east-1"
}

resource aviatrix_vpc fqdn_vpc_2 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "fqdn-vpc-2"
  region                = "us-east-2"
}
