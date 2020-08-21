data "aws_region" "current" {
  count = var.deploy == true ? 1 : 0
}

resource "aws_security_group" "sg" {
  count       = var.deploy == true ? 1 : 0
  name				= "allow_ssh_and_icmp"
	description	= "Allow SSH connection and ICMP to ubuntu instances."
	vpc_id			= var.vpc_id

	ingress {
	# SSH
	from_port		= 22
	to_port			= 22
	protocol		= "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
	# ICMP
	from_port		= -1
	to_port			=	-1
	protocol		= "icmp"
	cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
	# Allow all
	from_port 	= 0
	to_port 		= 0
	protocol 		= "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}

  tags = {
    Name  = "Ubuntu client Security Group"
    Owner = "Aviatrix"
  }
}

resource "aws_key_pair" "key_pair" {
  count      = var.deploy == true ? 1 : 0
  key_name   = "s2c_ubuntu_key_${uuid()}"
  public_key = file(var.public_key)
}

resource "aws_instance" "client" {
  count                       = var.deploy == true ? 1 : 0
  ami                         = lookup(var.ubuntu_ami,var.region)
  instance_type               = "t3.small"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg[0].id]
  key_name                    = aws_key_pair.key_pair[0].key_name
  tags = {
    Name = "Ubuntu client for S2C testing"
  }
}
