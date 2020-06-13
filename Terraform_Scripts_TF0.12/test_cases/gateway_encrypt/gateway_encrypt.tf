resource "aws_kms_key" "temp_cust_key" {
  description               = "Temporary customer key to encrypt Avx gateway volume"
  policy                    = file("policy.json")
  deletion_window_in_days   = null # do not set this
  is_enabled                = var.aws_kms_key_status
  enable_key_rotation       = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "temp_cust_key_alias" {
  name            = "alias/temp_cust_key"
  target_key_id   = aws_kms_key.temp_cust_key.id
}

resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "random_integer" "vpc2_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "aviatrix_vpc" "transit_encrypt_vpc" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-2"
  name                  = "transit-encrypt-vpc"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_vpc" "spoke_encrypt_vpc" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-2"
  name                  = "spoke-encrypt-vpc"
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_gateway" "aws_ebs_encrypt_gw" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  gw_name                 = "aws-ebs-encrypt-gw"
  vpc_id                  = aviatrix_vpc.transit_encrypt_vpc.vpc_id
  vpc_reg                 = aviatrix_vpc.transit_encrypt_vpc.region
  gw_size                 = "t2.micro"
  subnet                  = aviatrix_vpc.transit_encrypt_vpc.subnets.4.cidr
  single_az_ha            = false
  enable_encrypt_volume   = true
  customer_managed_keys   = aws_kms_key.temp_cust_key.id

  lifecycle {
    ignore_changes = [customer_managed_keys]
  }
}

resource "aviatrix_transit_gateway" "aws_ebs_encrypt_transit" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  gw_name                 = "aws-ebs-encrypt-transit"
  vpc_id                  = aviatrix_gateway.aws_ebs_encrypt_gw.vpc_id
  vpc_reg                 = aviatrix_gateway.aws_ebs_encrypt_gw.vpc_reg
  gw_size                 = "t2.micro"
  subnet                  = aviatrix_vpc.transit_encrypt_vpc.subnets.5.cidr
  enable_encrypt_volume   = true
  customer_managed_keys   = aws_kms_key.temp_cust_key.id

  lifecycle {
    ignore_changes = [customer_managed_keys]
  }
}

resource "aviatrix_spoke_gateway" "aws_ebs_encrypt_spoke" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  gw_name                 = "aws-ebs-encrypt-spoke"
  vpc_id                  = aviatrix_vpc.spoke_encrypt_vpc.vpc_id
  vpc_reg                 = aviatrix_vpc.spoke_encrypt_vpc.region
  gw_size                 = "t2.micro"
  subnet                  = aviatrix_vpc.spoke_encrypt_vpc.subnets.4.cidr
  enable_encrypt_volume   = true
  customer_managed_keys   = aws_kms_key.temp_cust_key.id

  lifecycle {
    ignore_changes = [customer_managed_keys]
  }
}

output "aws_ebs_encrypt_gw_id" {
  value = aviatrix_gateway.aws_ebs_encrypt_gw.id
}
output "aws_ebs_encrypt_transit_id" {
  value = aviatrix_transit_gateway.aws_ebs_encrypt_transit.id
}
output "aws_ebs_encrypt_spoke_id" {
  value = aviatrix_spoke_gateway.aws_ebs_encrypt_spoke.id
}

# CORRECT
# no encryption; no key PASS
# encryption; no key
# encryption; with key

# INCORRECT
# no encryption; with key
# encryption; incorrect key
# encryption; with key; singleaz
# encryption; no key; singleaz
