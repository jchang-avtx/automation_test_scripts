## Create Cloud VNet and Site VNet in the regions defined in variables.
## Deploy Aviatrix GWs in Cloud VNet and each Site VNet.
## Create back-to-back S2C connections from Cloud GW to each Site GW in different regions.
## Launch Ubuntu clients in Clound VNet and each Site VNet.
## Test end-to-end traffic and verify Site2Cloud connections

# Create an Azure Cloud VNet
resource "aviatrix_vpc" "arm_cloud_vnet" {
  cloud_type           = 8
  account_name         = var.aviatrix_arm_access_account
  region               = var.arm_cloud_region
  name                 = "cloud-vnet"
  cidr                 = "192.168.0.0/16"
  aviatrix_firenet_vpc = false
}

# Create multiple Azure Site VNets
resource "aviatrix_vpc" "arm_site_vnet" {
  count                = length(var.arm_site_region)
  cloud_type           = 8
  account_name         = var.aviatrix_arm_access_account
  region               = var.arm_site_region[count.index]
  name                 = "site-vpc-${replace(var.arm_site_region[count.index]," ","-")}"
  cidr                 = "10.${count.index}.0.0/16"
  aviatrix_firenet_vpc = false
}

data "aviatrix_vpc" "arm_cloud_vnet" {
  name       = aviatrix_vpc.arm_cloud_vnet.name
  depends_on = [aviatrix_vpc.arm_cloud_vnet]
}

# Create Aviatrix gateway in Cloud VNet
resource "aviatrix_gateway" "arm_cloud_gw" {
  cloud_type          = 8
  account_name        = var.aviatrix_arm_access_account
  gw_name             = "s2c-arm-cloud-gw"
  vpc_id              = aviatrix_vpc.arm_cloud_vnet.vpc_id
  vpc_reg             = var.arm_cloud_region
  gw_size             = "Standard_B1ms"
  subnet              = data.aviatrix_vpc.arm_cloud_vnet.public_subnets[0].cidr
}

data "aviatrix_vpc" "arm_site_vnet" {
  count      = length(var.arm_site_region)
  name       = aviatrix_vpc.arm_site_vnet[count.index].name
  depends_on = [aviatrix_vpc.arm_site_vnet]
}

#Create Aviatrix gateway in Site VNets
resource "aviatrix_gateway" "arm_site_gw" {
  count               = length(var.arm_site_region)
  cloud_type          = 8
  account_name        = var.aviatrix_arm_access_account
  gw_name             = "s2c-arm-site-gw-${replace(var.arm_site_region[count.index]," ","-")}"
  vpc_id              = aviatrix_vpc.arm_site_vnet[count.index].vpc_id
  vpc_reg             = var.arm_site_region[count.index]
  gw_size             = "Standard_B1ms"
  subnet              = data.aviatrix_vpc.arm_site_vnet[count.index].public_subnets[0].cidr
}

data "aviatrix_gateway" "arm_cloud_gw" {
  gw_name    = aviatrix_gateway.arm_cloud_gw.gw_name
  depends_on = [aviatrix_gateway.arm_cloud_gw]
}

data "aviatrix_gateway" "arm_site_gw" {
  count      = length(var.arm_site_region)
  gw_name    = aviatrix_gateway.arm_site_gw[count.index].gw_name
  depends_on = [aviatrix_gateway.arm_site_gw]
}

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "cloud_to_site" {
  count                      = length(var.arm_site_region)
  vpc_id                     = aviatrix_vpc.arm_cloud_vnet.vpc_id
  connection_name            = "cloud-to-site-${replace(var.arm_site_region[count.index]," ","-")}"
  connection_type            = "unmapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = aviatrix_gateway.arm_cloud_gw.gw_name
  remote_gateway_ip          = data.aviatrix_gateway.arm_site_gw[count.index].public_ip
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
  depends_on                 = [aviatrix_gateway.arm_cloud_gw,aviatrix_gateway.arm_site_gw]
}

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "site_to_cloud" {
  count                      = length(var.arm_site_region)
  vpc_id                     = data.aviatrix_gateway.arm_site_gw[count.index].vpc_id
  connection_name            = "site-to-cloud-${replace(var.arm_site_region[count.index]," ","-")}"
  connection_type            = "unmapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = data.aviatrix_gateway.arm_site_gw[count.index].gw_name
  remote_gateway_ip          = data.aviatrix_gateway.arm_cloud_gw.public_ip
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
  depends_on                 = [aviatrix_gateway.arm_cloud_gw,aviatrix_gateway.arm_site_gw]
}


######################################################
## Create Cloud Client for end-to-end traffic testing
######################################################

module "arm_cloud_client" {
  source       = "./arm_client"
  region       = var.arm_cloud_region
  vpc_id       = data.aviatrix_vpc.arm_cloud_vnet.vpc_id
  public_key   = var.public_key
  subnet_id    = data.aviatrix_vpc.arm_cloud_vnet.public_subnets[1].subnet_id
}


######################################################
## Create Site Client for end-to-end traffic testing
######################################################

module "arm_site_client" {
  count        = length(var.arm_site_region)
  source       = "./arm_client"
  region       = var.arm_site_region[count.index]
  vpc_id       = data.aviatrix_vpc.arm_site_vnet[count.index].vpc_id
  public_key   = var.public_key
  subnet_id    = data.aviatrix_vpc.arm_site_vnet[count.index].public_subnets[1].subnet_id
}

# Test end-to-end traffic
# Ping VM from Cloud VNet to other VMs in Site VNets located in different regions
locals {
  ping_hosts = join(",",flatten(module.arm_site_client.*.ubuntu_private_ip))
}
resource "null_resource" "ping" {
  depends_on = [
    aviatrix_site2cloud.cloud_to_site,
    aviatrix_site2cloud.site_to_cloud
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null test_traffic.py ${var.ssh_user}@${module.arm_cloud_client.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "echo '>>>>>>>>>>> The following Site Regions are tested <<<<<<<<<<<' > temp.txt",
      "echo ${join(",",var.arm_site_region)} >> temp.txt",
      "echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<' >> temp.txt",
      "python3 /tmp/test_traffic.py --ping_list ${local.ping_hosts}",
      "cat log.txt >> temp.txt && mv temp.txt log.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.arm_cloud_client.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.arm_cloud_client.ubuntu_public_ip[0]}:/tmp/*.txt ."
  }
}
