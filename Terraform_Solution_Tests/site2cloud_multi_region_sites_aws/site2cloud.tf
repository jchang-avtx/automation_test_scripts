## Create Cloud VPC and Site VPC in the regions defined in variables.
## Deploy Aviatrix GWs in Cloud VPC and each Site VPC.
## Create back-to-back S2C connections from Cloud GW to each Site GW in different regions.
## Launch Ubuntu clients in Clound VPC and each Site VPC.
## Test end-to-end traffic and verify Site2Cloud connections

# Create an AWS Cloud VPC
resource "aviatrix_vpc" "aws_cloud_vpc" {
  cloud_type           = 1
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_cloud_region
  name                 = "aws-cloud-vpc"
  cidr                 = "192.168.0.0/16"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

# Create multiple AWS Site VPCs
resource "aviatrix_vpc" "aws_site_vpc" {
  count                = length(var.aws_site_region)
  cloud_type           = 1
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_site_region[count.index]
  name                 = "aws-site-vpc_${var.aws_site_region[count.index]}"
  cidr                 = "10.${count.index}.0.0/16"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

data "aviatrix_vpc" "aws_cloud_vpc" {
  name       = aviatrix_vpc.aws_cloud_vpc.name
  depends_on = [aviatrix_vpc.aws_cloud_vpc]
}

# Create Aviatrix gateway in Cloud VPC
resource "aviatrix_gateway" "aws_cloud_gw" {
  cloud_type          = 1
  account_name        = var.aviatrix_aws_access_account
  gw_name             = "s2c-aws-cloud-gw"
  vpc_id              = aviatrix_vpc.aws_cloud_vpc.vpc_id
  vpc_reg             = var.aws_cloud_region
  gw_size             = "t3.small"
  subnet              = data.aviatrix_vpc.aws_cloud_vpc.public_subnets[0].cidr
}

data "aviatrix_vpc" "aws_site_vpc" {
  count      = length(var.aws_site_region)
  name       = aviatrix_vpc.aws_site_vpc[count.index].name
  depends_on = [aviatrix_vpc.aws_site_vpc]
}

#Create Aviatrix gateway in Site VPCs
resource "aviatrix_gateway" "aws_site_gw" {
  count               = length(var.aws_site_region)
  cloud_type          = 1
  account_name        = var.aviatrix_aws_access_account
  gw_name             = "s2c-aws-site-gw-${var.aws_site_region[count.index]}"
  vpc_id              = aviatrix_vpc.aws_site_vpc[count.index].vpc_id
  vpc_reg             = var.aws_site_region[count.index]
  gw_size             = "t3.small"
  subnet              = data.aviatrix_vpc.aws_site_vpc[count.index].public_subnets[0].cidr
}

data "aviatrix_gateway" "aws_cloud_gw" {
  gw_name    = aviatrix_gateway.aws_cloud_gw.gw_name
  depends_on = [aviatrix_gateway.aws_cloud_gw]
}

data "aviatrix_gateway" "aws_site_gw" {
  count      = length(var.aws_site_region)
  gw_name    = aviatrix_gateway.aws_site_gw[count.index].gw_name
  depends_on = [aviatrix_gateway.aws_site_gw]
}

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "cloud-to-site" {
  count                      = length(var.aws_site_region)
  vpc_id                     = aviatrix_vpc.aws_cloud_vpc.vpc_id
  connection_name            = "cloud-to-site-${var.aws_site_region[count.index]}"
  connection_type            = "unmapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = "s2c-aws-cloud-gw"
  remote_gateway_ip          = data.aviatrix_gateway.aws_site_gw[count.index].public_ip
  remote_subnet_cidr         = "10.${count.index}.0.0/16"
  local_subnet_cidr          = ""
  pre_shared_key             = var.pre_shared_key
  custom_algorithms          = true
  phase_1_authentication     = var.phase_1_authentication
  phase_2_authentication     = var.phase_2_authentication
  phase_1_dh_groups          = var.phase_1_dh_groups
  phase_2_dh_groups          = var.phase_2_dh_groups
  phase_1_encryption         = var.phase_1_encryption
  phase_2_encryption         = var.phase_2_encryption
  #depends_on                 = [aviatrix_gateway.aws_cloud_gw,aviatrix_gateway.aws_site_gw]
}

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "site-to-cloud" {
  count                      = length(var.aws_site_region)
  vpc_id                     = data.aviatrix_gateway.aws_site_gw[count.index].vpc_id
  connection_name            = "site-to-cloud-${var.aws_site_region[count.index]}"
  connection_type            = "unmapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = data.aviatrix_gateway.aws_site_gw[count.index].gw_name
  remote_gateway_ip          = data.aviatrix_gateway.aws_cloud_gw.public_ip
  remote_subnet_cidr         = "192.168.0.0/16"
  local_subnet_cidr          = ""
  pre_shared_key             = var.pre_shared_key
  custom_algorithms          = true
  phase_1_authentication     = var.phase_1_authentication
  phase_2_authentication     = var.phase_2_authentication
  phase_1_dh_groups          = var.phase_1_dh_groups
  phase_2_dh_groups          = var.phase_2_dh_groups
  phase_1_encryption         = var.phase_1_encryption
  phase_2_encryption         = var.phase_2_encryption
  #depends_on                 = [aviatrix_gateway.aws_cloud_gw,aviatrix_gateway.aws_site_gw]
}


######################################################
## Create Cloud Client for end-to-end traffic testing
######################################################

module "aws_cloud_client" {
  source  = "./aws_client"
  region     = var.aws_cloud_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = true
  vpc_id     = data.aviatrix_vpc.aws_cloud_vpc.vpc_id
  public_key = var.public_key
  subnet_id  = data.aviatrix_vpc.aws_cloud_vpc.public_subnets[1].subnet_id
}


######################################################
## Create Site Client for end-to-end traffic testing
######################################################

module "aws_client-us-east-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.NorthVirginia
  }
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"us-east-1")
  vpc_id     = contains(var.aws_site_region,"us-east-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-east-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"us-east-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-east-1")].public_subnets[1].subnet_id : null
}
module "aws_client-us-east-2" {
  source  = "./aws_client"
  providers = {
    aws = aws.Ohio
  }
  region     = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"us-east-2")
  vpc_id     = contains(var.aws_site_region,"us-east-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-east-2")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"us-east-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-east-2")].public_subnets[1].subnet_id : null
}
module "aws_client-us-west-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.NorthCalifornia
  }
  region     = "us-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"us-west-1")
  vpc_id     = contains(var.aws_site_region,"us-west-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-west-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"us-west-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-west-1")].public_subnets[1].subnet_id : null
}
module "aws_client-us-west-2" {
  source  = "./aws_client"
  providers = {
    aws = aws.Oregon
  }
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"us-west-2")
  vpc_id     = contains(var.aws_site_region,"us-west-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-west-2")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"us-west-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"us-west-2")].public_subnets[1].subnet_id : null
}
module "aws_client-af-south-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.CapeTown
  }
  region     = "af-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"af-south-1")
  vpc_id     = contains(var.aws_site_region,"af-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"af-south-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"af-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"af-south-1")].public_subnets[1].subnet_id : null
}
module "aws_client-ap-east-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.HongKong
  }
  region     = "ap-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ap-east-1")
  vpc_id     = contains(var.aws_site_region,"ap-east-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-east-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ap-east-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-east-1")].public_subnets[1].subnet_id : null
}
module "aws_client-ap-south-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Mumbai
  }
  region  = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ap-south-1")
  vpc_id  = contains(var.aws_site_region,"ap-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-south-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ap-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-south-1")].public_subnets[1].subnet_id : null
}
module "aws_client-ap-northeast-2" {
  source  = "./aws_client"
  providers = {
    aws = aws.Seoul
  }
  region  = "ap-northeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ap-northeast-2")
  vpc_id  = contains(var.aws_site_region,"ap-northeast-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-northeast-2")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ap-northeast-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-northeast-2")].public_subnets[1].subnet_id : null
}
module "aws_client-ap-southeast-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Singapore
  }
  region     = "ap-southeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ap-southeast-1")
  vpc_id     = contains(var.aws_site_region,"ap-southeast-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-southeast-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ap-southeast-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-southeast-1")].public_subnets[1].subnet_id : null
}
module "aws_client-ap-southeast-2" {
  source  = "./aws_client"
  providers = {
    aws = aws.Sydney
  }
  region     = "ap-southeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ap-southeast-2")
  vpc_id     = contains(var.aws_site_region,"ap-southeast-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-southeast-2")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ap-southeast-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-southeast-2")].public_subnets[1].subnet_id : null
}
module "aws_client-ap-northeast-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Tokyo
  }
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ap-northeast-1")
  vpc_id     = contains(var.aws_site_region,"ap-northeast-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-northeast-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ap-northeast-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ap-northeast-1")].public_subnets[1].subnet_id : null
}
module "aws_client-ca-central-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Canada
  }
  region     = "ca-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"ca-central-1")
  vpc_id     = contains(var.aws_site_region,"ca-central-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ca-central-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"ca-central-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"ca-central-1")].public_subnets[1].subnet_id : null
}
module "aws_client-eu-central-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Frankfurt
  }
  region     = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"eu-central-1")
  vpc_id     = contains(var.aws_site_region,"eu-central-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-central-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"eu-central-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-central-1")].public_subnets[1].subnet_id : null
}
module "aws_client-eu-west-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Ireland
  }
  region     = "eu-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"eu-west-1")
  vpc_id     = contains(var.aws_site_region,"eu-west-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-west-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"eu-west-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-west-1")].public_subnets[1].subnet_id : null
}
module "aws_client-eu-west-2" {
  source  = "./aws_client"
  providers = {
    aws = aws.London
  }
  region     = "eu-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"eu-west-2")
  vpc_id     = contains(var.aws_site_region,"eu-west-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-west-2")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"eu-west-2") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-west-2")].public_subnets[1].subnet_id : null
}
module "aws_client-eu-south-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Milan
  }
  region     = "eu-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"eu-south-1")
  vpc_id     = contains(var.aws_site_region,"eu-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-south-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"eu-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-south-1")].public_subnets[1].subnet_id : null
}
module "aws_client-eu-west-3" {
  source  = "./aws_client"
  providers = {
    aws = aws.Paris
  }
  region     = "eu-west-3"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"eu-west-3")
  vpc_id     = contains(var.aws_site_region,"eu-west-3") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-west-3")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"eu-west-3") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-west-3")].public_subnets[1].subnet_id : null
}
module "aws_client-eu-north-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Stockholm
  }
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"eu-north-1")
  vpc_id     = contains(var.aws_site_region,"eu-north-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-north-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"eu-north-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"eu-north-1")].public_subnets[1].subnet_id : null
}
module "aws_client-me-south-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.Bahrain
  }
  region     = "me-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"me-south-1")
  vpc_id     = contains(var.aws_site_region,"me-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"me-south-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"me-south-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"me-south-1")].public_subnets[1].subnet_id : null
}
module "aws_client-sa-east-1" {
  source  = "./aws_client"
  providers = {
    aws = aws.SaoPaulo
  }
  region     = "sa-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  deploy     = contains(var.aws_site_region,"sa-east-1")
  vpc_id     = contains(var.aws_site_region,"sa-east-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"sa-east-1")].vpc_id : null
  public_key = var.public_key
  subnet_id  = contains(var.aws_site_region,"sa-east-1") == true ? data.aviatrix_vpc.aws_site_vpc[index(var.aws_site_region,"sa-east-1")].public_subnets[1].subnet_id : null
}



# Test end-to-end traffic
# Ping VM from Cloud VPC to other VMs in Site VPCs located in different regions
locals {
  ping_hosts = join(",",
    module.aws_client-us-east-1.ubuntu_private_ip,
    module.aws_client-us-east-2.ubuntu_private_ip,
    module.aws_client-us-west-1.ubuntu_private_ip,
    module.aws_client-us-west-2.ubuntu_private_ip,
    module.aws_client-af-south-1.ubuntu_private_ip,
    module.aws_client-ap-east-1.ubuntu_private_ip,
    module.aws_client-ap-south-1.ubuntu_private_ip,
    module.aws_client-ap-northeast-2.ubuntu_private_ip,
    module.aws_client-ap-southeast-1.ubuntu_private_ip,
    module.aws_client-ap-southeast-2.ubuntu_private_ip,
    module.aws_client-ap-northeast-1.ubuntu_private_ip,
    module.aws_client-ca-central-1.ubuntu_private_ip,
    module.aws_client-eu-central-1.ubuntu_private_ip,
    module.aws_client-eu-west-1.ubuntu_private_ip,
    module.aws_client-eu-west-2.ubuntu_private_ip,
    module.aws_client-eu-south-1.ubuntu_private_ip,
    module.aws_client-eu-west-3.ubuntu_private_ip,
    module.aws_client-eu-north-1.ubuntu_private_ip,
    module.aws_client-me-south-1.ubuntu_private_ip,
    module.aws_client-sa-east-1.ubuntu_private_ip,
    )
}
resource "null_resource" "ping" {
  depends_on = [
    aviatrix_site2cloud.cloud-to-site,
    aviatrix_site2cloud.site-to-cloud,
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null test_traffic.py ${var.ssh_user}@${module.aws_cloud_client.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "echo '>>>>>>>>>>> The following Site Regions are tested <<<<<<<<<<<' > temp.txt",
      "echo ${join(",",var.aws_site_region)} >> temp.txt",
      "echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<' >> temp.txt",
      "python3 /tmp/test_traffic.py --ping_list ${local.ping_hosts}",
      "cat log.txt >> temp.txt && mv temp.txt log.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws_cloud_client.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws_cloud_client.ubuntu_public_ip[0]}:/tmp/*.txt ."
  }
}
