#########################
##### AWS resources #####
#########################

## Create AWS VPC Transit side
## -----------------------------------
# Internet VPC
resource "aws_vpc" "transit-VPC" {
    count = "${var.transit}"
    cidr_block = "192.169.${count.index}.0/24"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "transit-VPC-${count.index}-${var.region1}"
    }
}
# Subnets
resource "aws_subnet" "transit-VPC-public" {
    count = "${var.transit}"
    vpc_id = "${element(aws_vpc.transit-VPC.*.id,count.index)}"
    cidr_block = "192.169.${count.index}.0/24"
    map_public_ip_on_launch = "true"
    tags {
        Name = "transit-VPC-public-${count.index}"
    }
}

# Internet GW
resource "aws_internet_gateway" "transit-VPC-gw" {
    count = "${var.transit}"
    vpc_id = "${element(aws_vpc.transit-VPC.*.id,count.index)}"
    tags {
        Name = "transit-VPC-gw-${count.index}"
    }
}
# route tables
resource "aws_route_table" "transit-VPC-route" {
    count = "${var.transit}"
    vpc_id = "${element(aws_vpc.transit-VPC.*.id,count.index)}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(aws_internet_gateway.transit-VPC-gw.*.id,count.index)}"
    }
    tags {
        Name = "transit-VPC-route-${count.index}"
    }
    lifecycle {
        ignore_changes = ["route"]
    }
}

# route associations public
resource "aws_route_table_association" "transit-VPC-ra" {
    count = "${var.transit}"
    subnet_id = "${element(aws_subnet.transit-VPC-public.*.id,count.index)}"
    route_table_id = "${element(aws_route_table.transit-VPC-route.*.id,count.index)}"
    depends_on = ["aws_subnet.transit-VPC-public","aws_route_table.transit-VPC-route","aws_internet_gateway.transit-VPC-gw","aws_vpc.transit-VPC"]
}
## END -------------------------------


## Create AWS VPC SPOKE side
## -----------------------------------

# Internet VPC
resource "aws_vpc" "spoke-VPC" {
    count = "${var.spoke_gateways}"
    cidr_block = "10.1.${count.index}.0/24"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "test-spoke-VPC-${count.index}-${var.region1}"
    }
    depends_on = ["aws_route_table_association.transit-VPC-ra"]
}
# Subnets
resource "aws_subnet" "spoke-VPC-public" {
    count = "${var.spoke_gateways}"
    vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
    cidr_block = "10.1.${count.index}.0/24"
    map_public_ip_on_launch = "true"
    tags {
        Name = "spoke-VPC-public-${count.index}-${var.region1}"
    }
}
# Internet GW
resource "aws_internet_gateway" "spoke-VPC-gw" {
    count = "${var.spoke_gateways}"
    vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
    tags {
        Name = "spoke-VPC-gw-${count.index}-${var.region1}"
    }
}
# route tables
resource "aws_route_table" "spoke-VPC-route" {
    count = "${var.spoke_gateways}"
    vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(aws_internet_gateway.spoke-VPC-gw.*.id,count.index)}"
    }
    lifecycle {
        ignore_changes = ["route"]
    }
    tags {
        Name = "spoke-VPC-route-${count.index}-${var.region1}"
    }
    depends_on = ["aws_vpc.spoke-VPC","aws_internet_gateway.spoke-VPC-gw"]
}

# route associations public
resource "aws_route_table_association" "spoke-VPC-ra" {
    count = "${var.spoke_gateways}"
    subnet_id = "${element(aws_subnet.spoke-VPC-public.*.id,count.index)}"
    route_table_id = "${element(aws_route_table.spoke-VPC-route.*.id,count.index)}"
    depends_on = ["aws_subnet.spoke-VPC-public","aws_route_table.spoke-VPC-route","aws_internet_gateway.spoke-VPC-gw","aws_vpc.spoke-VPC"]
}
## END -------------------------------

## Create SPOKE Linux VM Instances
## -----------------------------------
#Spoke Linux VMs
resource "aws_instance" "spoke-Linux" {
  ami           = "${lookup(var.AMI, var.region1)}"
  instance_type = "${var.t2instance}"
  count = "${var.spoke_gateways}"

  # the VPC subnet
  subnet_id = "${element(aws_subnet.spoke-VPC-public.*.id,count.index)}"

  # the security group
  vpc_security_group_ids = ["${element(aws_security_group.allow-ssh-ping-spoke-VPC.*.id,count.index)}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"

  tags{
    Name = "spoke-Linux-${count.index}-${var.region1}"
  } 
}
## END -------------------------------



## Create AWS SHARED VPC side
## -----------------------------------
# Internet VPC
resource "aws_vpc" "shared-VPC" {
    count = "${var.shared_gateways}"
    cidr_block = "10.224.${count.index}.0/24"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "test-shared-VPC-${count.index}-${var.region1}"
    }
}

# Subnets
resource "aws_subnet" "shared-VPC-public" {
    count = "${var.shared_gateways}"
    vpc_id = "${element(aws_vpc.shared-VPC.*.id,count.index)}"
    cidr_block = "10.224.${count.index}.0/24"
    map_public_ip_on_launch = "true"
    tags {
        Name = "shared-VPC-public-${count.index}-${var.region1}"
    }
}
# Internet GW
resource "aws_internet_gateway" "shared-VPC-gw" {
    count = "${var.shared_gateways}"
    vpc_id = "${element(aws_vpc.shared-VPC.*.id,count.index)}"
    tags {
        Name = "shared-VPC-gw-${count.index}-${var.region1}"
    }
}

# route tables
resource "aws_route_table" "shared-VPC-route" {
    count = "${var.shared_gateways}"
    vpc_id = "${element(aws_vpc.shared-VPC.*.id,count.index)}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(aws_internet_gateway.shared-VPC-gw.*.id,count.index)}"
    }
    lifecycle {
        ignore_changes = ["route"]
    }
    tags {
        Name = "shared-VPC-route-${count.index}-${var.region1}"
    }
    depends_on = ["aws_vpc.shared-VPC","aws_internet_gateway.shared-VPC-gw"]
}

# route associations public
resource "aws_route_table_association" "shared-VPC-ra" {
    count = "${var.shared_gateways}"
    subnet_id = "${element(aws_subnet.shared-VPC-public.*.id,count.index)}"
    route_table_id = "${element(aws_route_table.shared-VPC-route.*.id,count.index)}"
    depends_on = ["aws_subnet.shared-VPC-public","aws_route_table.shared-VPC-route","aws_internet_gateway.shared-VPC-gw","aws_vpc.shared-VPC"]
}
## END -------------------------------

## Create SHARED Linux VM Instances
## -----------------------------------
resource "aws_instance" "shared-Linux" {
  ami           = "${lookup(var.AMI, var.region1)}"
  instance_type = "${var.t2instance}"
  count = "${var.shared_gateways}"
  # the VPC subnet
  subnet_id = "${element(aws_subnet.shared-VPC-public.*.id,count.index)}"
  # the security group
  vpc_security_group_ids = ["${element(aws_security_group.allow-ssh-ping-shared-VPC.*.id,count.index)}"]
  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"

  tags{
    Name = "shared-Linux-${count.index}-${var.region1}"
  } 
}
## END -------------------------------

## Security Group Spoke Side
## -----------------------------------
resource "aws_security_group" "allow-ssh-ping-spoke-VPC" {
  count = "${var.spoke_gateways}"
  vpc_id = "${element(aws_vpc.spoke-VPC.*.id,count.index)}"
  name = "allow-ssh-spoke-${count.index}"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow-ssh-ping"
  }
}
## END -------------------------------

## Security Group Shared Services Side
## -----------------------------------
resource "aws_security_group" "allow-ssh-ping-shared-VPC" {
  count = "${var.shared_gateways}"
  vpc_id = "${element(aws_vpc.shared-VPC.*.id,count.index)}"
  name = "allow-ssh-shared-${count.index}"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow-ssh-ping-shared"
  }
}
## END -------------------------------

## Security Group OnPrem Side
## -----------------------------------
resource "aws_security_group" "allow-ssh-ping-Prem" {
  vpc_id = "${aws_vpc.OnPrem-VPC.id}"
  name = "allow-ssh-onprem"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow-ssh-ping-onprem"
  }
}
## END -------------------------------

## Create OnPrem VPC
## -----------------------------------
# Internet VPC
resource "aws_vpc" "OnPrem-VPC" {
    cidr_block = "172.16.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "OnPrem-VPC-${var.region1}"
    }
}
# Subnets
resource "aws_subnet" "OnPrem-VPC-public" {
    vpc_id = "${aws_vpc.OnPrem-VPC.id}"
    cidr_block = "172.16.0.0/16"
    map_public_ip_on_launch = "true"
    tags {
        Name = "OnPrem-VPC-public-${var.region1}"
    }
}
# Internet GW
resource "aws_internet_gateway" "OnPrem-VPC-gw" {
    vpc_id = "${aws_vpc.OnPrem-VPC.id}"
    tags {
        Name = "OnPrem-VPC-gw-${var.region1}"
    }
}
# route tables
resource "aws_route_table" "OnPrem-VPC-route" {
    vpc_id = "${aws_vpc.OnPrem-VPC.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.OnPrem-VPC-gw.id}"
    }
    tags {
        Name = "OnPrem-VPC-route-${var.region1}"
    }
}
# route associations public
resource "aws_route_table_association" "OnPrem-VPC-ra" {
    subnet_id = "${aws_subnet.OnPrem-VPC-public.id}"
    route_table_id = "${aws_route_table.OnPrem-VPC-route.id}"
    depends_on = ["aws_subnet.OnPrem-VPC-public","aws_route_table.OnPrem-VPC-route","aws_internet_gateway.OnPrem-VPC-gw","aws_vpc.OnPrem-VPC"]
}
## END -------------------------------


# Create OnPrem Linux VM
## -----------------------------------
resource "aws_instance" "Linux-On-Prem" {
    ami           = "${lookup(var.AMI, var.region1)}"
    instance_type = "${var.t2instance}"
    # the VPC subnet
    subnet_id = "${aws_subnet.OnPrem-VPC-public.id}"
    # the security group
    vpc_security_group_ids = ["${aws_security_group.allow-ssh-ping-Prem.id}"]
    # the public SSH key
    key_name = "${aws_key_pair.mykeypair.key_name}"
    tags {
        Name = "Linux-On-Prem"
    } 
}

## END -------------------------------

## Create AWS customer gateway & VGW towards aviatrix OnPrem Gateway
## -----------------------------------------------------------------
resource "aws_customer_gateway" "customer_gateway" {
    bgp_asn    = 6588
    ip_address = "${aviatrix_gateway.OnPrem-GW.public_ip}"
    type       = "ipsec.1"
    tags {
       Name = "onprem-gateway"
    }
}
resource "aws_vpn_connection" "onprem" {
    vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
    customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
    type                = "ipsec.1"
    static_routes_only  = true
    tags {
       Name = "site2cloud-to-vgw"
    }
}
# original onprem CIDR block
resource "aws_vpn_connection_route" "onprem1" {
    destination_cidr_block = "${aws_subnet.OnPrem-VPC-public.cidr_block}"
    vpn_connection_id = "${aws_vpn_connection.onprem.id}"
}
# 2nd static route from onprem 
resource "aws_vpn_connection_route" "onprem2" {
    destination_cidr_block = "100.100.100.0/24"
    vpn_connection_id = "${aws_vpn_connection.onprem.id}"
}
## END -------------------------------
