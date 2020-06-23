module "aws-spoke-vpc" {
  source                 = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	             = 3
  resource_name_label  	 = "SDNAT-Spoke-VPC"
  pub_hostnum		         = 10
  pri_hostnum		         = 20
  vpc_cidr        	     = ["10.1.0.0/16","10.2.0.0/16","10.3.0.0/16"]
  pub_subnet1_cidr       = ["10.1.0.0/24","10.2.0.0/24","10.3.0.0/24"]
  pub_subnet2_cidr       = ["10.1.1.0/24","10.2.1.0/24","10.3.1.0/24"]
  pri_subnet_cidr        = ["10.1.2.0/24","10.2.2.0/24","10.3.2.0/24"]
  public_key      	     = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		         = "" # default empty will set to ubuntu 18.04 ami
}

module "aws-onprem-vpc" {
  source                 = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	             = 1
  resource_name_label	   = "SDNAT-OnPrem-VPC"
  pub_hostnum		         = 30
  pri_hostnum		         = 40
  vpc_cidr        	     = ["10.3.0.0/16"]
  pub_subnet1_cidr       = ["10.3.3.0/24"]
  pub_subnet2_cidr       = ["10.3.2.0/24"]
  pri_subnet_cidr        = ["10.3.4.0/24"]
  public_key      	     = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		         = "" # default empty will set to ubuntu 18.04 ami
}

#Create AWS Transit VPC
resource "aviatrix_vpc" "cloud-transit-vpc" {
  cloud_type           = var.cloud_type
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_region
  name                 = "SDNAT-Cloud-Transit-VPC"
  cidr                 = "192.168.0.0/16"
  aviatrix_transit_vpc = true
  aviatrix_firenet_vpc = false
}

#Create an Aviatrix AWS Transit Network Gateway
resource "aviatrix_transit_gateway" "Cloud-Transit-GW" {
  cloud_type               = var.cloud_type
  account_name             = var.aviatrix_aws_access_account
  gw_name                  = "SDNAT-Cloud-Transit-GW"
  vpc_id                   = aviatrix_vpc.cloud-transit-vpc.vpc_id
  vpc_reg                  = var.aws_region
  gw_size                  = "t3.small"
  subnet                   = aviatrix_vpc.cloud-transit-vpc.subnets[4].cidr
  single_ip_snat           = false
  enable_active_mesh       = true
  connected_transit        = true
  ha_subnet                = aviatrix_vpc.cloud-transit-vpc.subnets[5].cidr
  ha_gw_size               = "t3.small"
}

# Create OnPrem Transit GW for simulating OnPrem router
resource "aviatrix_transit_gateway" "OnPrem-Transit-GW" {
  cloud_type               = var.cloud_type
  account_name             = var.aviatrix_aws_access_account
  gw_name                  = "SDNAT-OnPrem-Transit-GW"
  vpc_id                   = module.aws-onprem-vpc.vpc_id[0]
  vpc_reg                  = var.aws_region
  gw_size                  = "t3.micro"
  subnet                   = module.aws-onprem-vpc.subnet_cidr[0]
  single_ip_snat           = false
  enable_active_mesh       = true
  connected_transit        = false

  # Advertise BGP routes for OnPrem Hosts
  bgp_manual_spoke_advertise_cidrs = "10.3.3.30/32,10.3.4.40/32"
}

#Create an Aviatrix AWS Spoke Gateway-1 in Spoke_VPC1
resource "aviatrix_spoke_gateway" "Spoke-GW-1" {
  depends_on                 = [module.aws-spoke-vpc]
  cloud_type                 = var.cloud_type
  account_name               = var.aviatrix_aws_access_account
  gw_name                    = "SDNAT-Spoke-GW-1"
  vpc_id                     = module.aws-spoke-vpc.vpc_id[0]
  vpc_reg                    = var.aws_region
  gw_size                    = "t3.micro"
  subnet                     = module.aws-spoke-vpc.subnet_cidr[0]
  transit_gw                 = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
  enable_active_mesh         = true
  included_advertised_spoke_routes = "10.1.0.0/16,99.1.0.0/16"
  ha_subnet                  = module.aws-spoke-vpc.subnet_cidr[3]
  ha_gw_size                 = "t3.micro"
}

#Create an Aviatrix AWS Spoke Gateway-2 in Spoke_VPC2
resource "aviatrix_spoke_gateway" "Spoke-GW-2" {
  depends_on                 = [module.aws-spoke-vpc]
  cloud_type                 = var.cloud_type
  account_name               = var.aviatrix_aws_access_account
  gw_name                    = "SDNAT-Spoke-GW-2"
  vpc_id                     = module.aws-spoke-vpc.vpc_id[1]
  vpc_reg                    = var.aws_region
  gw_size                    = "t3.micro"
  subnet                     = module.aws-spoke-vpc.subnet_cidr[1]
  transit_gw                 = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
  enable_active_mesh         = true
}

#Create an Aviatrix AWS Spoke Gateway-3 in Spoke_VPC3
resource "aviatrix_spoke_gateway" "Spoke-GW-3" {
  depends_on                 = [module.aws-spoke-vpc]
  cloud_type                 = var.cloud_type
  account_name               = var.aviatrix_aws_access_account
  gw_name                    = "SDNAT-Spoke-GW-3"
  vpc_id                     = module.aws-spoke-vpc.vpc_id[2]
  vpc_reg                    = var.aws_region
  gw_size                    = "t3.micro"
  subnet                     = module.aws-spoke-vpc.subnet_cidr[2]
  transit_gw                 = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
  enable_active_mesh         = true
  included_advertised_spoke_routes = "10.3.0.0/16,99.3.0.0/16"
  ha_subnet                  = module.aws-spoke-vpc.subnet_cidr[5]
  ha_gw_size                 = "t3.micro"
}

#Create AWS VGW
resource "aws_vpn_gateway" "vpn_gateway" {
  tags = {
    Name = "SDNAT-VGW"
  }
}

# Create an Aviatrix VGW Connection Cloud-to-VGW
resource "aviatrix_vgw_conn" "Cloud-to-VGW" {
  conn_name        = "Cloud-to-VGW"
  gw_name          = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
  vpc_id           = aviatrix_transit_gateway.Cloud-Transit-GW.vpc_id
  bgp_vgw_id       = aws_vpn_gateway.vpn_gateway.id
  bgp_vgw_account  = var.aviatrix_aws_access_account
  bgp_vgw_region   = var.aws_region
  bgp_local_as_num = "65001"
}
# Create an Aviatrix VGW Connection OnPrem-to-VGW
resource "aviatrix_vgw_conn" "OnPrem-to-VGW" {
  conn_name        = "OnPrem-to-VGW"
  gw_name          = aviatrix_transit_gateway.OnPrem-Transit-GW.gw_name
  vpc_id           = aviatrix_transit_gateway.OnPrem-Transit-GW.vpc_id
  bgp_vgw_id       = aws_vpn_gateway.vpn_gateway.id
  bgp_vgw_account  = var.aviatrix_aws_access_account
  bgp_vgw_region   = var.aws_region
  bgp_local_as_num = "65002"
}

# Spoke-1 SNAT config
resource "aviatrix_gateway_snat" "SDNAT-Spoke-GW-1" {
  gw_name    = aviatrix_spoke_gateway.Spoke-GW-1.gw_name
  depends_on = [aviatrix_spoke_gateway.Spoke-GW-1]
  snat_mode  = "customized_snat"
  snat_policy {
      src_cidr    = "10.1.0.0/16"
      src_port    = ""
      dst_cidr    = "10.3.4.40/32"
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = ""
      snat_ips    = "99.1.0.1"
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "991010"
      snat_ips    = aviatrix_spoke_gateway.Spoke-GW-1.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "991220"
      snat_ips    = aviatrix_spoke_gateway.Spoke-GW-1.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
}
data "aws_instance" "SDNAT-Spoke-GW-1-HA" {
  instance_id = aviatrix_spoke_gateway.Spoke-GW-1.ha_cloud_instance_id
}
resource "aviatrix_gateway_snat" "SDNAT-Spoke-GW-1-HA" {
  gw_name    = format("%s-hagw",aviatrix_spoke_gateway.Spoke-GW-1.gw_name)
  depends_on = [aviatrix_gateway_snat.SDNAT-Spoke-GW-1]
  snat_mode  = "customized_snat"
  snat_policy {
      src_cidr    = "10.1.0.0/16"
      src_port    = ""
      dst_cidr    = "10.3.4.40/32"
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = ""
      snat_ips    = "99.1.0.2"
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "991010"
      snat_ips    = data.aws_instance.SDNAT-Spoke-GW-1-HA.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "991220"
      snat_ips    = data.aws_instance.SDNAT-Spoke-GW-1-HA.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
}

# Spoke-1 DNAT config
resource "aviatrix_gateway_dnat" "SDNAT-Spoke-GW-1" {
  gw_name    = aviatrix_spoke_gateway.Spoke-GW-1.gw_name
  depends_on = [aviatrix_spoke_gateway.Spoke-GW-1]
  dnat_policy {
      src_cidr    = "10.3.4.40/32"
      src_port    = ""
      dst_cidr    = "99.1.0.10/32"
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = "991010"
      dnat_ips    = "10.1.0.10"
      dnat_port   = ""
      exclude_rtb = ""
  }
  dnat_policy {
      src_cidr    = "10.3.4.40/32"
      src_port    = ""
      dst_cidr    = "99.1.2.20/32"
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = "991220"
      dnat_ips    = "10.1.2.20"
      dnat_port   = ""
      exclude_rtb = ""
  }
}

# Spoke-3 SNAT config
resource "aviatrix_gateway_snat" "SDNAT-Spoke-GW-3" {
  gw_name    = aviatrix_spoke_gateway.Spoke-GW-3.gw_name
  depends_on = [aviatrix_spoke_gateway.Spoke-GW-3]
  snat_mode  = "customized_snat"
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = "883440"
      snat_ips    = "99.3.0.1"
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "993010"
      snat_ips    = aviatrix_spoke_gateway.Spoke-GW-3.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "993220"
      snat_ips    = aviatrix_spoke_gateway.Spoke-GW-3.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
}
data "aws_instance" "SDNAT-Spoke-GW-3-HA" {
  instance_id = aviatrix_spoke_gateway.Spoke-GW-3.ha_cloud_instance_id
}
resource "aviatrix_gateway_snat" "SDNAT-Spoke-GW-3-HA" {
  gw_name    = format("%s-hagw",aviatrix_spoke_gateway.Spoke-GW-3.gw_name)
  depends_on = [aviatrix_gateway_snat.SDNAT-Spoke-GW-3]
  snat_mode  = "customized_snat"
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = "883440"
      snat_ips    = "99.3.0.2"
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "993010"
      snat_ips    = data.aws_instance.SDNAT-Spoke-GW-3-HA.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
  snat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = ""
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "993220"
      snat_ips    = data.aws_instance.SDNAT-Spoke-GW-3-HA.private_ip
      snat_port   = ""
      exclude_rtb = ""
  }
}

# Spoke-3 DNAT config
resource "aviatrix_gateway_dnat" "SDNAT-Spoke-GW-3" {
  gw_name    = aviatrix_spoke_gateway.Spoke-GW-3.gw_name
  depends_on = [aviatrix_spoke_gateway.Spoke-GW-3]
  dnat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = "88.3.4.40/32"
      dst_port    = ""
      protocol    = "all"
      interface   = "eth0"
      connection  = "None"
      mark        = "883440"
      dnat_ips    = "10.3.4.40"
      dnat_port   = ""
      exclude_rtb = ""
  }
  dnat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = "99.3.0.10/32"
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = "993010"
      dnat_ips    = "10.3.0.10"
      dnat_port   = ""
      exclude_rtb = ""
  }
  dnat_policy {
      src_cidr    = ""
      src_port    = ""
      dst_cidr    = "99.3.2.20/32"
      dst_port    = ""
      protocol    = "all"
      interface   = ""
      connection  = aviatrix_transit_gateway.Cloud-Transit-GW.gw_name
      mark        = "993220"
      dnat_ips    = "10.3.2.20"
      dnat_port   = ""
      exclude_rtb = ""
  }
}

#Add Spoke routes to OnPremVPC public subnet route table
data "aws_subnet" "onprem_public" {
  cidr_block  = module.aws-onprem-vpc.subnet_cidr[0]
  depends_on  = [aviatrix_transit_gateway.OnPrem-Transit-GW]
}
data "aws_route_table" "onprem_public" {
  subnet_id   = data.aws_subnet.onprem_public.id
  depends_on  = [aviatrix_transit_gateway.OnPrem-Transit-GW]
}
resource "aws_route" "onprem_public" {
  route_table_id         = data.aws_route_table.onprem_public.id
  destination_cidr_block = "99.0.0.0/8"
  instance_id            = aviatrix_transit_gateway.OnPrem-Transit-GW.cloud_instance_id
}

#Add Spoke routes to OnPremVPC private subnet route table
data "aws_subnet" "onprem_private" {
  cidr_block  = module.aws-onprem-vpc.subnet_cidr[2]
  depends_on  = [aviatrix_transit_gateway.OnPrem-Transit-GW]
}
data "aws_route_table" "onprem_private" {
  subnet_id   = data.aws_subnet.onprem_private.id
  depends_on  = [aviatrix_transit_gateway.OnPrem-Transit-GW]
}
resource "aws_route" "onprem_private" {
  route_table_id         = data.aws_route_table.onprem_private.id
  destination_cidr_block = "99.0.0.0/8"
  instance_id            = aviatrix_transit_gateway.OnPrem-Transit-GW.cloud_instance_id
}

# Test end-to-end traffic
# Spoke1 hosts ping to "10.2.0.10,10.2.2.20,10.3.2.20,10.3.4.40"
# Spoke2 hosts ping to "10.1.0.10,10.1.2.20,10.3.2.20"
# Spoke3 hosts ping to "10.1.0.10,10.2.0.10,10.1.2.20,10.2.2.20,88.3.4.40"
# OnPrem host 10.3.4.40 pings to "99.1.0.10,99.1.2.20,99.3.0.10,99.3.2.20"
locals {
  all_public_hosts    = join(" ",[for i in range(3): module.aws-spoke-vpc.ubuntu_public_ip[i]],[module.aws-onprem-vpc.ubuntu_public_ip[0]])
  spoke1_ping_targets = join(",",[for i in [1,4,5]: module.aws-spoke-vpc.ubuntu_private_ip[i]],[module.aws-onprem-vpc.ubuntu_private_ip[1]])
  spoke2_ping_targets = join(",",[for i in [0,3,5]: module.aws-spoke-vpc.ubuntu_private_ip[i]])
  spoke3_ping_targets = join(",",[for i in [0,1,3,4]: module.aws-spoke-vpc.ubuntu_private_ip[i]],["88.3.4.40"])
  onprem_ping_targets = join(",",["99.1.0.10","99.1.2.20","99.3.0.10","99.3.2.20"])
}
resource "null_resource" "ping" {
  depends_on = [
    module.aws-spoke-vpc.ubuntu_public_ip,
    aviatrix_vgw_conn.Cloud-to-VGW,
    aviatrix_vgw_conn.OnPrem-to-VGW,
    aviatrix_spoke_gateway.Spoke-GW-1,
    aviatrix_spoke_gateway.Spoke-GW-3
  ]

  triggers = {
    key = "${uuid()}"
  }

  # This provisioner will copy test_traffic.py to all public VM instances
  provisioner "local-exec" {
    command = "for host in ${local.all_public_hosts}; do scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null test_traffic.py ${var.ssh_user}@$host:/tmp/ ; done"
  }

  # Copy private key to public instance in order to ssh to private instance
  provisioner "local-exec" {
    command = "for host in ${local.all_public_hosts}; do scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.private_key} ${var.ssh_user}@$host:.ssh/id_rsa ; done"
  }

  # Traffic test for Spoke1
  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/test_traffic.py --ping_list ${local.spoke1_ping_targets}",
      "sed -i '1i>>>>>>>>>> Ping Test initiated from Spoke1 Public instance <<<<<<<<<' /tmp/log.txt",
      "scp -o StrictHostKeyChecking=no /tmp/test_traffic.py ${module.aws-spoke-vpc.ubuntu_private_ip[3]}:/tmp/",
      "echo '>>>>>>>>>> Ping Test initiated from Spoke1 Private instance <<<<<<<<<<' >> /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.aws-spoke-vpc.ubuntu_private_ip[3]} python3 /tmp/test_traffic.py --ping_list ${local.spoke1_ping_targets}",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.aws-spoke-vpc.ubuntu_private_ip[3]} cat /tmp/log.txt >> /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.aws-spoke-vpc.ubuntu_private_ip[3]} cat /tmp/result.txt >> /tmp/result.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-spoke-vpc.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Traffic test for Spoke2
  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/test_traffic.py --ping_list ${local.spoke2_ping_targets}",
      "sed -i '1i>>>>>>>>>> Ping Test initiated from Spoke2 Public instance <<<<<<<<<<' /tmp/log.txt",
      "scp -o StrictHostKeyChecking=no /tmp/test_traffic.py ${module.aws-spoke-vpc.ubuntu_private_ip[4]}:/tmp/",
      "echo '>>>>>>>>>> Ping Test initiated from Spoke2 Private instance <<<<<<<<<<' >> /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.aws-spoke-vpc.ubuntu_private_ip[4]} python3 /tmp/test_traffic.py --ping_list ${local.spoke2_ping_targets}",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.aws-spoke-vpc.ubuntu_private_ip[4]} cat /tmp/log.txt >> /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.aws-spoke-vpc.ubuntu_private_ip[4]} cat /tmp/result.txt >> /tmp/result.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-spoke-vpc.ubuntu_public_ip[1]
      agent = false
    }
  }

  # Traffic test for Spoke3
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no /tmp/test_traffic.py ${module.aws-spoke-vpc.ubuntu_private_ip[5]}:/tmp/",
      "echo '>>>>>>>>>> Ping Test initiated from Spoke3 Private instance <<<<<<<<<<' > /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no ${module.aws-spoke-vpc.ubuntu_private_ip[5]} python3 /tmp/test_traffic.py --ping_list ${local.spoke3_ping_targets}",
      "ssh -o StrictHostKeyChecking=no ${module.aws-spoke-vpc.ubuntu_private_ip[5]} cat /tmp/log.txt >> /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no ${module.aws-spoke-vpc.ubuntu_private_ip[5]} cat /tmp/result.txt > /tmp/result.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-spoke-vpc.ubuntu_public_ip[2]
      agent = false
    }
  }

  # Traffic test for OnPrem
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no /tmp/test_traffic.py ${module.aws-onprem-vpc.ubuntu_private_ip[1]}:/tmp/",
      "echo '>>>>>>>>>> Ping Test initiated from OnPrem instance <<<<<<<<<<' > /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no ${module.aws-onprem-vpc.ubuntu_private_ip[1]} python3 /tmp/test_traffic.py --ping_list ${local.onprem_ping_targets}",
      "ssh -o StrictHostKeyChecking=no ${module.aws-onprem-vpc.ubuntu_private_ip[1]} cat /tmp/log.txt >> /tmp/log.txt",
      "ssh -o StrictHostKeyChecking=no ${module.aws-onprem-vpc.ubuntu_private_ip[1]} cat /tmp/result.txt > /tmp/result.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-onprem-vpc.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Once test is done, prepare for log file and result file
  provisioner "local-exec" {
    command = "echo 'FINAL TREAFFIC TEST REPORT' > log.txt; echo '==========================' >> log.txt; echo > result.txt"
  }
  provisioner "local-exec" {
    command = "for host in ${local.all_public_hosts}; do ssh -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@$host cat /tmp/log.txt >> log.txt; done"
  }
  provisioner "local-exec" {
    command = "for host in ${local.all_public_hosts}; do ssh -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@$host cat /tmp/result.txt >> result.txt; done"
  }
  provisioner "local-exec" {
    command = "if grep 'FAIL' result.txt; then echo 'FAIL' > result.txt; else echo 'PASS' > result.txt; fi"
  }
}
