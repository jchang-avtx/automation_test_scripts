## Create Cloud VPC and Site VPC in the regions defined in variables.
## Deploy Aviatrix GWs in Cloud VPC and each Site VPC.
## Create back-to-back S2C connections from Cloud GW to each Site GW in different regions.
## Launch Ubuntu clients in Clound VPC and each Site VPC.
## Test end-to-end traffic and verify Site2Cloud connections

# Create a GCP Cloud VPC
resource "aviatrix_vpc" "gcp_cloud_vpc" {
  cloud_type           = 4
  account_name         = var.aviatrix_gcp_access_account
  name                 = "cloud-vpc-${var.gcp_cloud_region}"

  subnets {
    name   = "subnet-1-${substr(uuid(),0,6)}"
    region = var.gcp_cloud_region
    cidr   = "192.168.0.0/16"
  }
}

# Create multiple GCP Site VPCs
resource "aviatrix_vpc" "gcp_site_vpc" {
  count                = length(var.gcp_site_region)
  cloud_type           = 4
  account_name         = var.aviatrix_gcp_access_account
  name                 = "site-${var.gcp_site_region[count.index]}"

  subnets {
    name   = "subnet-1-${substr(uuid(),0,6)}"
    region = var.gcp_site_region[count.index]
    cidr   = "10.${count.index}.0.0/16"
  }
}

data "google_compute_zones" "cloud_region" {
  region  = var.gcp_cloud_region
}

# Create Aviatrix gateway in Cloud VPC
resource "aviatrix_gateway" "gcp_cloud_gw" {
  cloud_type          = 4
  account_name        = var.aviatrix_gcp_access_account
  gw_name             = "s2c-gcp-cloud-gw"
  vpc_id              = aviatrix_vpc.gcp_cloud_vpc.vpc_id
  vpc_reg             = data.google_compute_zones.cloud_region.names[0]
  gw_size             = "n1-standard-1"
  subnet              = aviatrix_vpc.gcp_cloud_vpc.subnets[0].cidr
}

data "google_compute_zones" "site_region" {
  count  = length(var.gcp_site_region)
  region = var.gcp_site_region[count.index]
}

# Create Aviatrix gateway in Site VPCs
resource "aviatrix_gateway" "gcp_site_gw" {
  count               = length(var.gcp_site_region)
  cloud_type          = 4
  account_name        = var.aviatrix_gcp_access_account
  gw_name             = "s2c-gcp-site-gw-${var.gcp_site_region[count.index]}"
  vpc_id              = aviatrix_vpc.gcp_site_vpc[count.index].vpc_id
  vpc_reg             = data.google_compute_zones.site_region[count.index].names[0]
  gw_size             = "n1-standard-1"
  subnet              = aviatrix_vpc.gcp_site_vpc[count.index].subnets[0].cidr
}

data "aviatrix_gateway" "gcp_cloud_gw" {
  gw_name    = aviatrix_gateway.gcp_cloud_gw.gw_name
  depends_on = [aviatrix_gateway.gcp_cloud_gw]
}

data "aviatrix_gateway" "gcp_site_gw" {
  count      = length(var.gcp_site_region)
  gw_name    = aviatrix_gateway.gcp_site_gw[count.index].gw_name
  depends_on = [aviatrix_gateway.gcp_site_gw]
}

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "cloud_to_site" {
  count                      = length(var.gcp_site_region)
  vpc_id                     = "${aviatrix_vpc.gcp_cloud_vpc.vpc_id}~-~${var.gcp_project_name}"
  connection_name            = "cloud-to-site-${var.gcp_site_region[count.index]}"
  connection_type            = "unmapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = aviatrix_gateway.gcp_cloud_gw.gw_name
  remote_gateway_ip          = data.aviatrix_gateway.gcp_site_gw[count.index].public_ip
  remote_subnet_cidr         = aviatrix_vpc.gcp_site_vpc[count.index].subnets[0].cidr
  local_subnet_cidr          = ""
  pre_shared_key             = var.pre_shared_key
  custom_algorithms          = true
  phase_1_authentication     = var.phase_1_authentication
  phase_2_authentication     = var.phase_2_authentication
  phase_1_dh_groups          = var.phase_1_dh_groups
  phase_2_dh_groups          = var.phase_2_dh_groups
  phase_1_encryption         = var.phase_1_encryption
  phase_2_encryption         = var.phase_2_encryption
  depends_on                 = [aviatrix_gateway.gcp_cloud_gw,aviatrix_gateway.gcp_site_gw]
}

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "site_to_cloud" {
  count                      = length(var.gcp_site_region)
  vpc_id                     = "${data.aviatrix_gateway.gcp_site_gw[count.index].vpc_id}~-~${var.gcp_project_name}"
  connection_name            = "site-to-cloud-${var.gcp_site_region[count.index]}"
  connection_type            = "unmapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = data.aviatrix_gateway.gcp_site_gw[count.index].gw_name
  remote_gateway_ip          = data.aviatrix_gateway.gcp_cloud_gw.public_ip
  remote_subnet_cidr         = aviatrix_vpc.gcp_cloud_vpc.subnets[0].cidr
  local_subnet_cidr          = ""
  pre_shared_key             = var.pre_shared_key
  custom_algorithms          = true
  phase_1_authentication     = var.phase_1_authentication
  phase_2_authentication     = var.phase_2_authentication
  phase_1_dh_groups          = var.phase_1_dh_groups
  phase_2_dh_groups          = var.phase_2_dh_groups
  phase_1_encryption         = var.phase_1_encryption
  phase_2_encryption         = var.phase_2_encryption
  depends_on                 = [aviatrix_gateway.gcp_cloud_gw,aviatrix_gateway.gcp_site_gw]
}


######################################################
## Create Cloud Client for end-to-end traffic testing
######################################################

module "gcp_cloud_client" {
  source       = "./gcp_client"
  region       = var.gcp_cloud_region
  vpc_id       = aviatrix_vpc.gcp_cloud_vpc.vpc_id
  ssh_user     = var.ssh_user
  public_key   = var.public_key
  subnet_name  = aviatrix_vpc.gcp_cloud_vpc.subnets[0].name
}


######################################################
## Create Site Client for end-to-end traffic testing
######################################################

module "gcp_site_client" {
  count        = length(var.gcp_site_region)
  source       = "./gcp_client"
  region       = var.gcp_site_region[count.index]
  vpc_id       = aviatrix_vpc.gcp_site_vpc[count.index].vpc_id
  ssh_user     = var.ssh_user
  public_key   = var.public_key
  subnet_name  = aviatrix_vpc.gcp_site_vpc[count.index].subnets[0].name
}


# Test end-to-end traffic
# Ping VM from Cloud VPC to other VMs in Site VPCs located in different regions
locals {
  ping_hosts = join(",",flatten(module.gcp_site_client.*.ubuntu_private_ip))
}
resource "null_resource" "ping" {
  depends_on = [
    aviatrix_site2cloud.cloud_to_site,
    aviatrix_site2cloud.site_to_cloud,
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null test_traffic.py ${var.ssh_user}@${module.gcp_cloud_client.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "echo '>>>>>>>>>>> The following Site Regions are tested <<<<<<<<<<<' > temp.txt",
      "echo ${join(",",var.gcp_site_region)} >> temp.txt",
      "echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<' >> temp.txt",
      "python3 /tmp/test_traffic.py --ping_list ${local.ping_hosts}",
      "cat log.txt >> temp.txt && mv temp.txt log.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.gcp_cloud_client.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.gcp_cloud_client.ubuntu_public_ip[0]}:/tmp/*.txt ."
  }
}
